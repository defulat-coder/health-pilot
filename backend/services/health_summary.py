from datetime import date, datetime
from typing import Any

from sqlalchemy import func

from config import settings
from models.database import Exercise, Meal, Notification, SessionLocal, UserProfile


def build_health_summary(user_id: str = "default", *, today: date | None = None) -> dict[str, Any]:
    """Build the mobile client's daily health summary for one user."""
    summary_date = today or datetime.now().date()
    start = datetime.combine(summary_date, datetime.min.time())
    end = datetime.combine(summary_date, datetime.max.time())

    db = SessionLocal()
    try:
        profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        meal_totals = _meal_totals(db, user_id, start, end)
        exercise_totals = _exercise_totals(db, user_id, start, end)
        target_rate = _target_rate(profile)
        tdee = profile.tdee_kcal if profile and profile.tdee_kcal else None
        daily_target = tdee - target_rate * 1100 if tdee else None
        protein_target = _protein_target(profile)
        remaining_calories = (
            daily_target - meal_totals["calories"] + exercise_totals["calories"]
            if daily_target
            else None
        )
        notifications = _unread_notifications(db, user_id)

        return {
            "user_id": user_id,
            "profile": {
                "is_complete": bool(profile and profile.tdee_kcal),
                "height_cm": profile.height_cm if profile else None,
                "weight_kg": profile.weight_kg if profile else None,
                "age": profile.age if profile else None,
                "gender": profile.gender if profile else None,
                "activity_level": profile.activity_level if profile else None,
                "target_weight_kg": profile.target_weight_kg if profile else None,
                "target_rate_kg_per_week": target_rate,
                "tdee_kcal": tdee,
                "daily_calorie_target_kcal": daily_target,
            },
            "today": {
                "date": summary_date.isoformat(),
                "calories_consumed_kcal": meal_totals["calories"],
                "calorie_target_kcal": daily_target,
                "remaining_calories_kcal": remaining_calories,
                "protein_g": meal_totals["protein"],
                "protein_target_g": protein_target,
                "carbs_g": meal_totals["carbs"],
                "fat_g": meal_totals["fat"],
                "exercise_calories_kcal": exercise_totals["calories"],
                "exercise_minutes": exercise_totals["minutes"],
                "meal_count": meal_totals["count"],
            },
            "notifications": [
                {
                    "id": notification.id,
                    "trigger_type": notification.trigger_type,
                    "trigger_name": notification.trigger_name,
                    "content": notification.content,
                    "created_at": (
                        notification.created_at.isoformat()
                        if notification.created_at
                        else None
                    ),
                }
                for notification in notifications
            ],
        }
    finally:
        db.close()


def _target_rate(profile: UserProfile | None) -> float:
    if profile and profile.target_rate_kg_per_week:
        return profile.target_rate_kg_per_week
    return settings.default_target_rate_kg_per_week


def _protein_target(profile: UserProfile | None) -> float:
    weight_kg = profile.weight_kg if profile and profile.weight_kg else 70
    return weight_kg * settings.protein_target_per_kg


def _meal_totals(db, user_id: str, start: datetime, end: datetime) -> dict[str, float]:
    row = (
        db.query(
            func.sum(Meal.calories_kcal),
            func.sum(Meal.protein_g),
            func.sum(Meal.carbs_g),
            func.sum(Meal.fat_g),
            func.count(Meal.id),
        )
        .filter(
            Meal.user_id == user_id,
            Meal.recorded_at >= start,
            Meal.recorded_at <= end,
        )
        .one()
    )
    return {
        "calories": row[0] or 0,
        "protein": row[1] or 0,
        "carbs": row[2] or 0,
        "fat": row[3] or 0,
        "count": row[4] or 0,
    }


def _exercise_totals(db, user_id: str, start: datetime, end: datetime) -> dict[str, float]:
    row = (
        db.query(
            func.sum(Exercise.calories_burned),
            func.sum(Exercise.duration_minutes),
        )
        .filter(
            Exercise.user_id == user_id,
            Exercise.recorded_at >= start,
            Exercise.recorded_at <= end,
        )
        .one()
    )
    return {
        "calories": row[0] or 0,
        "minutes": row[1] or 0,
    }


def _unread_notifications(db, user_id: str) -> list[Notification]:
    return (
        db.query(Notification)
        .filter(
            Notification.user_id == user_id,
            Notification.delivered == False,
        )
        .order_by(Notification.created_at.desc())
        .limit(5)
        .all()
    )
