from datetime import datetime, timedelta

from agno.agent import Agent
from agno.models.openai import OpenAILike
from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy import func

from config import settings
from models.database import (
    Exercise,
    Meal,
    Notification,
    SessionLocal,
    UserProfile,
    Weight,
)

push_agent = Agent(
    name="Push Generator",
    model=OpenAILike(
        id=settings.llm_model,
        api_key=settings.llm_api_key,
        base_url=settings.llm_base_url,
    ),
    instructions=(
        "你是减脂教练的推送内容生成器。根据用户数据生成简短、温暖、个性化的推送消息。"
        "消息要简洁（1-2句话），包含具体数据和建议。使用用户的饮食偏好来推荐食物。"
    ),
    markdown=False,
)

scheduler = BackgroundScheduler()


def _get_user_context(db, user_id: str) -> dict:
    today = datetime.now().date()
    start = datetime.combine(today, datetime.min.time())
    end = datetime.combine(today, datetime.max.time())

    profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
    total_cal = db.query(func.sum(Meal.calories_kcal)).filter(
        Meal.user_id == user_id, Meal.recorded_at >= start, Meal.recorded_at <= end
    ).scalar() or 0
    total_protein = db.query(func.sum(Meal.protein_g)).filter(
        Meal.user_id == user_id, Meal.recorded_at >= start, Meal.recorded_at <= end
    ).scalar() or 0
    meal_count = db.query(func.count(Meal.id)).filter(
        Meal.user_id == user_id, Meal.recorded_at >= start, Meal.recorded_at <= end
    ).scalar() or 0

    return {
        "profile": profile,
        "today_calories": total_cal,
        "today_protein": total_protein,
        "today_meal_count": meal_count,
        "tdee": profile.tdee_kcal if profile else None,
        "target_protein": (profile.weight_kg or 70) * settings.protein_target_per_kg if profile else 112,
    }


def _generate_push(user_id: str, trigger_name: str, prompt: str):
    response = push_agent.run(prompt)
    content = response.content if response else ""

    db = SessionLocal()
    try:
        notification = Notification(
            user_id=user_id,
            trigger_type="scheduled" if "reminder" in trigger_name or "report" in trigger_name else "conditional",
            trigger_name=trigger_name,
            content=content,
        )
        db.add(notification)
        db.commit()
    finally:
        db.close()


def _run_scheduled_push(trigger_name: str):
    db = SessionLocal()
    try:
        profiles = db.query(UserProfile).all()
        for profile in profiles:
            schedule = profile.push_schedule or settings.default_push_schedule
            ctx = _get_user_context(db, profile.user_id)

            if trigger_name == "breakfast_reminder":
                prompt = f"用户TDEE {ctx['tdee'] or '未知'}kcal，生成早餐提醒推送，推荐高蛋白早餐。"
            elif trigger_name == "lunch_reminder":
                remaining = (ctx["tdee"] or 1800) - ctx["today_calories"]
                prompt = f"用户今天已摄入{ctx['today_calories']:.0f}kcal，还剩{remaining:.0f}kcal，生成午餐提醒推送，推荐合适的午餐。"
            elif trigger_name == "dinner_reminder":
                remaining = (ctx["tdee"] or 1800) - ctx["today_calories"]
                protein_gap = ctx["target_protein"] - ctx["today_protein"]
                prompt = f"用户今天已摄入{ctx['today_calories']:.0f}kcal（还剩{remaining:.0f}kcal），蛋白质还差{protein_gap:.0f}g，生成晚餐提醒，建议补充蛋白质的菜品。"
            elif trigger_name == "weigh_in_reminder":
                prompt = "生成一条温馨的称重提醒推送。"
            elif trigger_name == "weekly_report":
                prompt = f"用户本周数据：已记录{ctx['today_meal_count']}餐。生成简短的周报鼓励推送。"
            else:
                continue

            _generate_push(profile.user_id, trigger_name, prompt)
    finally:
        db.close()


def check_conditional_triggers(user_id: str):
    """Call after each data record to check conditional push triggers."""
    db = SessionLocal()
    try:
        ctx = _get_user_context(db, user_id)
        if not ctx["profile"] or not ctx["tdee"]:
            return

        tdee = ctx["tdee"]
        today = datetime.now().date()
        start = datetime.combine(today, datetime.min.time())
        end = datetime.combine(today, datetime.max.time())

        already_sent = set(
            n.trigger_name for n in db.query(Notification).filter(
                Notification.user_id == user_id,
                Notification.created_at >= start,
                Notification.created_at <= end,
            ).all()
        )

        # 热量接近上限
        if ctx["today_calories"] >= tdee * 0.9 and "calorie_high" not in already_sent:
            remaining = tdee - ctx["today_calories"]
            _generate_push(
                user_id, "calorie_high",
                f"用户今天已摄入{ctx['today_calories']:.0f}kcal，目标{tdee:.0f}kcal，只剩{remaining:.0f}kcal。生成友善提醒。"
            )

        # 蛋白质不达标（晚餐时段检查）
        hour = datetime.now().hour
        if hour >= 17 and ctx["today_protein"] < ctx["target_protein"] * 0.5 and "protein_low" not in already_sent:
            gap = ctx["target_protein"] - ctx["today_protein"]
            _generate_push(
                user_id, "protein_low",
                f"用户蛋白质还差{gap:.0f}g，目标{ctx['target_protein']:.0f}g。推荐高蛋白食物。"
            )

        # 连续达标鼓励
        recent_days = 3
        on_target_days = 0
        for i in range(recent_days):
            d = today - timedelta(days=i)
            d_start = datetime.combine(d, datetime.min.time())
            d_end = datetime.combine(d, datetime.max.time())
            day_cal = db.query(func.sum(Meal.calories_kcal)).filter(
                Meal.user_id == user_id, Meal.recorded_at >= d_start, Meal.recorded_at <= d_end
            ).scalar() or 0
            if 0 < day_cal <= tdee:
                on_target_days += 1

        if on_target_days >= 3 and "streak" not in already_sent:
            _generate_push(
                user_id, "streak",
                f"用户连续{on_target_days}天热量达标！生成鼓励推送。"
            )

        # 体重平台期
        weights = db.query(Weight).filter(
            Weight.user_id == user_id,
            Weight.recorded_at >= datetime.combine(today - timedelta(days=7), datetime.min.time()),
        ).order_by(Weight.recorded_at).all()

        if len(weights) >= 5 and "plateau" not in already_sent:
            weight_range = max(w.weight_kg for w in weights) - min(w.weight_kg for w in weights)
            if weight_range < 0.3:
                _generate_push(
                    user_id, "plateau",
                    "用户体重连续7天波动小于0.3kg，可能进入平台期。生成建议推送，建议调整饮食或增加运动变化。"
                )
    finally:
        db.close()


def check_silent_users():
    """检查沉默用户并发送关怀推送（每天定时执行）"""
    db = SessionLocal()
    try:
        today = datetime.now().date()
        start_of_yesterday = datetime.combine(today - timedelta(days=1), datetime.min.time())
        end_of_today = datetime.combine(today, datetime.max.time())
        
        profiles = db.query(UserProfile).all()
        for profile in profiles:
            user_id = profile.user_id
            
            # 检查当日是否已发送过沉默唤醒
            already_sent = db.query(Notification).filter(
                Notification.user_id == user_id,
                Notification.trigger_name == "silent_wakeup",
                Notification.created_at >= datetime.combine(today, datetime.min.time())
            ).first()
            
            if already_sent:
                continue

            # 检查过去24/48小时是否有记录
            recent_meal = db.query(Meal).filter(
                Meal.user_id == user_id,
                Meal.recorded_at >= start_of_yesterday
            ).first()
            
            recent_exercise = db.query(Exercise).filter(
                Exercise.user_id == user_id,
                Exercise.recorded_at >= start_of_yesterday
            ).first()
            
            if not recent_meal and not recent_exercise:
                _generate_push(
                    user_id, "silent_wakeup",
                    "用户已经超过一天没有记录饮食或运动了。生成一条温暖的沉默唤醒推送，比如问问是不是太忙了，提醒好好吃饭。"
                )
    finally:
        db.close()


def init_scheduler():
    """Initialize the push scheduler with default times."""
    schedule = settings.default_push_schedule

    for trigger_name, time_str in schedule.items():
        if trigger_name == "weekly_report":
            parts = time_str.split()
            day = parts[0].lower()
            t = parts[1].split(":")
            day_map = {"monday": "mon", "tuesday": "tue", "wednesday": "wed", "thursday": "thu", "friday": "fri", "saturday": "sat", "sunday": "sun"}
            scheduler.add_job(
                _run_scheduled_push,
                "cron",
                day_of_week=day_map.get(day, "sun"),
                hour=int(t[0]),
                minute=int(t[1]),
                args=[trigger_name],
                id=trigger_name,
                replace_existing=True,
            )
        else:
            t = time_str.split(":")
            scheduler.add_job(
                _run_scheduled_push,
                "cron",
                hour=int(t[0]),
                minute=int(t[1]),
                args=[trigger_name],
                id=trigger_name,
                replace_existing=True,
            )

    # 添加沉默用户检查任务 (每天20:00执行)
    scheduler.add_job(
        check_silent_users,
        "cron",
        hour=20,
        minute=0,
        id="silent_wakeup_check",
        replace_existing=True,
    )

    scheduler.start()


def shutdown_scheduler():
    scheduler.shutdown(wait=False)
