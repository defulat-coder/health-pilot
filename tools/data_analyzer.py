from datetime import datetime, timedelta

from agno.run import RunContext
from sqlalchemy import func

from config import settings
from models.database import Exercise, Meal, SessionLocal, UserProfile, Weight


def get_daily_summary(run_context: RunContext, date: str = "") -> str:
    """获取用户当日营养与运动摘要。

    Args:
        date (str): 日期，格式 YYYY-MM-DD，留空则为今天
    """
    user_id = run_context.user_id or "default"
    target_date = datetime.strptime(date, "%Y-%m-%d").date() if date else datetime.now().date()
    start = datetime.combine(target_date, datetime.min.time())
    end = datetime.combine(target_date, datetime.max.time())

    db = SessionLocal()
    try:
        meals = db.query(Meal).filter(
            Meal.user_id == user_id,
            Meal.recorded_at >= start,
            Meal.recorded_at <= end,
        ).all()

        exercises = db.query(Exercise).filter(
            Exercise.user_id == user_id,
            Exercise.recorded_at >= start,
            Exercise.recorded_at <= end,
        ).all()

        profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()

        total_cal = sum(m.calories_kcal for m in meals)
        total_protein = sum(m.protein_g for m in meals)
        total_carbs = sum(m.carbs_g for m in meals)
        total_fat = sum(m.fat_g for m in meals)
        total_exercise_cal = sum(e.calories_burned for e in exercises)

        tdee = profile.tdee_kcal if profile and profile.tdee_kcal else 0
        calorie_gap = tdee - total_cal + total_exercise_cal if tdee else None

        protein_target = (profile.weight_kg or 70) * settings.protein_target_per_kg if profile else 70 * settings.protein_target_per_kg
        protein_pct = (total_protein / protein_target * 100) if protein_target else 0

        lines = [
            f"📊 {target_date} 数据摘要",
            f"已摄入：{total_cal:.0f}kcal" + (f" / 目标 {tdee:.0f}kcal" if tdee else ""),
            f"蛋白质：{total_protein:.0f}g / {protein_target:.0f}g ({protein_pct:.0f}%)",
            f"碳水：{total_carbs:.0f}g | 脂肪：{total_fat:.0f}g",
            f"运动消耗：{total_exercise_cal:.0f}kcal",
        ]
        if calorie_gap is not None:
            lines.append(f"热量缺口：{calorie_gap:.0f}kcal")

        meal_details = []
        for m in meals:
            meal_details.append(f"  - {m.meal_type}: {m.description} ({m.calories_kcal:.0f}kcal)")
        if meal_details:
            lines.append("饮食明细：")
            lines.extend(meal_details)

        return "\n".join(lines)
    finally:
        db.close()


def get_weekly_summary(run_context: RunContext) -> str:
    """获取用户本周营养、运动和体重摘要。"""
    user_id = run_context.user_id or "default"
    today = datetime.now().date()
    week_start = today - timedelta(days=today.weekday())
    start = datetime.combine(week_start, datetime.min.time())
    end = datetime.combine(today, datetime.max.time())
    days = (today - week_start).days + 1

    db = SessionLocal()
    try:
        meals = db.query(Meal).filter(
            Meal.user_id == user_id,
            Meal.recorded_at >= start,
            Meal.recorded_at <= end,
        ).all()

        exercises = db.query(Exercise).filter(
            Exercise.user_id == user_id,
            Exercise.recorded_at >= start,
            Exercise.recorded_at <= end,
        ).all()

        total_cal = sum(m.calories_kcal for m in meals)
        total_protein = sum(m.protein_g for m in meals)
        total_exercise_cal = sum(e.calories_burned for e in exercises)
        exercise_days = len(set(e.recorded_at.date() for e in exercises))

        weight_trend = _calc_weight_trend(db, user_id, today)
        weekly_rate = _calc_weekly_rate(db, user_id, today)

        lines = [
            f"📈 本周摘要 ({week_start} ~ {today})",
            f"日均摄入：{total_cal / days:.0f}kcal",
            f"日均蛋白质：{total_protein / days:.0f}g",
            f"总运动消耗：{total_exercise_cal:.0f}kcal ({exercise_days}天运动)",
        ]
        if weight_trend is not None:
            lines.append(f"趋势体重：{weight_trend:.1f}kg")
        if weekly_rate is not None:
            direction = "减" if weekly_rate > 0 else "增"
            lines.append(f"周均{direction}重：{abs(weekly_rate):.2f}kg/周")

        return "\n".join(lines)
    finally:
        db.close()


def get_monthly_summary(run_context: RunContext) -> str:
    """获取用户本月营养与体重摘要。"""
    user_id = run_context.user_id or "default"
    today = datetime.now().date()
    month_start = today.replace(day=1)
    start = datetime.combine(month_start, datetime.min.time())
    end = datetime.combine(today, datetime.max.time())
    days = (today - month_start).days + 1

    db = SessionLocal()
    try:
        avg_cal = db.query(func.avg(Meal.calories_kcal)).filter(
            Meal.user_id == user_id,
            Meal.recorded_at >= start,
            Meal.recorded_at <= end,
        ).scalar() or 0

        meal_count = db.query(func.count(Meal.id)).filter(
            Meal.user_id == user_id,
            Meal.recorded_at >= start,
            Meal.recorded_at <= end,
        ).scalar() or 0

        first_weight = db.query(Weight).filter(
            Weight.user_id == user_id,
            Weight.recorded_at >= start,
        ).order_by(Weight.recorded_at.asc()).first()

        last_weight = db.query(Weight).filter(
            Weight.user_id == user_id,
            Weight.recorded_at <= end,
        ).order_by(Weight.recorded_at.desc()).first()

        lines = [
            f"📊 本月摘要 ({month_start} ~ {today})",
            f"共记录 {meal_count} 餐 ({days} 天)",
        ]
        if first_weight and last_weight:
            change = last_weight.weight_kg - first_weight.weight_kg
            direction = "减" if change < 0 else "增"
            lines.append(f"体重变化：{first_weight.weight_kg:.1f}kg → {last_weight.weight_kg:.1f}kg ({direction}{abs(change):.1f}kg)")

        return "\n".join(lines)
    finally:
        db.close()


def get_weight_trend(run_context: RunContext) -> str:
    """获取7日移动平均趋势体重及周变化速率。"""
    user_id = run_context.user_id or "default"
    today = datetime.now().date()

    db = SessionLocal()
    try:
        trend = _calc_weight_trend(db, user_id, today)
        rate = _calc_weekly_rate(db, user_id, today)

        if trend is None:
            return "暂无足够体重数据，建议每天称重记录。"

        lines = [f"趋势体重（7日均值）：{trend:.1f}kg"]
        if rate is not None:
            direction = "减" if rate > 0 else "增"
            lines.append(f"周均{direction}重速率：{abs(rate):.2f}kg/周")
        return "\n".join(lines)
    finally:
        db.close()


def get_protein_status(run_context: RunContext) -> str:
    """获取今日蛋白质摄入量与基于体重的目标对比。"""
    user_id = run_context.user_id or "default"
    today = datetime.now().date()
    start = datetime.combine(today, datetime.min.time())
    end = datetime.combine(today, datetime.max.time())

    db = SessionLocal()
    try:
        total_protein = db.query(func.sum(Meal.protein_g)).filter(
            Meal.user_id == user_id,
            Meal.recorded_at >= start,
            Meal.recorded_at <= end,
        ).scalar() or 0

        profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        weight = profile.weight_kg if profile and profile.weight_kg else 70
        target = weight * settings.protein_target_per_kg
        pct = total_protein / target * 100 if target else 0

        return (
            f"蛋白质：{total_protein:.0f}g / {target:.0f}g ({pct:.0f}%)\n"
            f"(基于体重 {weight:.0f}kg × {settings.protein_target_per_kg}g/kg)"
        )
    finally:
        db.close()


def _calc_weight_trend(db, user_id: str, ref_date) -> float | None:
    start = datetime.combine(ref_date - timedelta(days=6), datetime.min.time())
    end = datetime.combine(ref_date, datetime.max.time())
    weights = db.query(Weight).filter(
        Weight.user_id == user_id,
        Weight.recorded_at >= start,
        Weight.recorded_at <= end,
    ).all()
    if len(weights) < 3:
        return None
    return sum(w.weight_kg for w in weights) / len(weights)


def _calc_weekly_rate(db, user_id: str, ref_date) -> float | None:
    current_trend = _calc_weight_trend(db, user_id, ref_date)
    prev_trend = _calc_weight_trend(db, user_id, ref_date - timedelta(days=7))
    if current_trend is None or prev_trend is None:
        return None
    return prev_trend - current_trend
