from datetime import datetime
from typing import Optional

from agno.run import RunContext

from config import settings
from models.database import SessionLocal, UserProfile


def _calc_tdee(height_cm: float, weight_kg: float, age: int, gender: str, activity_level: str) -> float:
    """Mifflin-St Jeor equation"""
    if gender == "male":
        bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    else:
        bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age - 161

    multipliers = {
        "sedentary": 1.2,
        "light": 1.375,
        "moderate": 1.55,
        "heavy": 1.725,
    }
    return bmr * multipliers.get(activity_level, 1.2)


def update_user_profile(
    run_context: RunContext,
    height_cm: Optional[float] = None,
    weight_kg: Optional[float] = None,
    age: Optional[int] = None,
    gender: Optional[str] = None,
    activity_level: Optional[str] = None,
    target_weight_kg: Optional[float] = None,
    target_rate_kg_per_week: Optional[float] = None,
) -> str:
    """Create or update the user's profile. Call this when the user provides personal info like height, weight, age, gender, activity level, or sets weight loss goals.

    Args:
        height_cm (float): Height in centimeters
        weight_kg (float): Current weight in kilograms
        age (int): Age in years
        gender (str): "male" or "female"
        activity_level (str): One of "sedentary", "light", "moderate", "heavy"
        target_weight_kg (float): Target weight in kilograms
        target_rate_kg_per_week (float): Target weight loss rate per week in kg
    """
    user_id = run_context.user_id or "default"

    db = SessionLocal()
    try:
        profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        if not profile:
            profile = UserProfile(
                user_id=user_id,
                push_schedule=settings.default_push_schedule,
                target_rate_kg_per_week=settings.default_target_rate_kg_per_week,
            )
            db.add(profile)

        if height_cm is not None:
            profile.height_cm = height_cm
        if weight_kg is not None:
            profile.weight_kg = weight_kg
        if age is not None:
            profile.age = age
        if gender is not None:
            profile.gender = gender
        if activity_level is not None:
            profile.activity_level = activity_level
        if target_weight_kg is not None:
            profile.target_weight_kg = target_weight_kg
        if target_rate_kg_per_week is not None:
            profile.target_rate_kg_per_week = target_rate_kg_per_week

        profile.updated_at = datetime.utcnow()

        if all([profile.height_cm, profile.weight_kg, profile.age, profile.gender, profile.activity_level]):
            profile.tdee_kcal = _calc_tdee(
                profile.height_cm, profile.weight_kg, profile.age, profile.gender, profile.activity_level
            )

        db.commit()

        lines = ["用户档案已更新："]
        if profile.height_cm:
            lines.append(f"  身高：{profile.height_cm:.0f}cm")
        if profile.weight_kg:
            lines.append(f"  体重：{profile.weight_kg:.1f}kg")
        if profile.age:
            lines.append(f"  年龄：{profile.age}岁")
        if profile.gender:
            lines.append(f"  性别：{'男' if profile.gender == 'male' else '女'}")
        if profile.activity_level:
            lines.append(f"  活动量：{profile.activity_level}")
        if profile.tdee_kcal:
            daily_target = profile.tdee_kcal - (profile.target_rate_kg_per_week or 0.5) * 1100
            lines.append(f"  TDEE：{profile.tdee_kcal:.0f}kcal")
            lines.append(f"  建议每日摄入：{daily_target:.0f}kcal（减脂目标 {profile.target_rate_kg_per_week:.1f}kg/周）")
        if profile.target_weight_kg:
            lines.append(f"  目标体重：{profile.target_weight_kg:.1f}kg")

        return "\n".join(lines)
    finally:
        db.close()


def update_push_schedule(
    run_context: RunContext,
    breakfast_reminder: Optional[str] = None,
    lunch_reminder: Optional[str] = None,
    dinner_reminder: Optional[str] = None,
    weigh_in_reminder: Optional[str] = None,
) -> str:
    """Update the user's push notification schedule. Call this when the user wants to change reminder times.

    Args:
        breakfast_reminder (str): Time for breakfast reminder, e.g. "08:00"
        lunch_reminder (str): Time for lunch reminder, e.g. "12:00"
        dinner_reminder (str): Time for dinner reminder, e.g. "18:00"
        weigh_in_reminder (str): Time for weigh-in reminder, e.g. "07:30"
    """
    user_id = run_context.user_id or "default"

    db = SessionLocal()
    try:
        profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        if not profile:
            return "请先完善个人信息档案。"

        schedule = profile.push_schedule or dict(settings.default_push_schedule)
        if breakfast_reminder:
            schedule["breakfast_reminder"] = breakfast_reminder
        if lunch_reminder:
            schedule["lunch_reminder"] = lunch_reminder
        if dinner_reminder:
            schedule["dinner_reminder"] = dinner_reminder
        if weigh_in_reminder:
            schedule["weigh_in_reminder"] = weigh_in_reminder

        profile.push_schedule = schedule
        profile.updated_at = datetime.utcnow()
        db.commit()

        lines = ["推送时间已更新："]
        for k, v in schedule.items():
            lines.append(f"  {k}: {v}")
        return "\n".join(lines)
    finally:
        db.close()
