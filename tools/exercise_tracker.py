from datetime import datetime

from agno.run import RunContext

from models.database import Exercise, SessionLocal


def record_exercise(
    run_context: RunContext,
    exercise_type: str,
    duration_minutes: int,
    calories_burned: float,
) -> str:
    """Record an exercise session. Call this when the user reports exercise, sends a fitness app screenshot, or describes a workout.

    Args:
        exercise_type (str): Type of exercise, e.g. "跑步", "游泳", "力量训练"
        duration_minutes (int): Duration in minutes
        calories_burned (float): Estimated calories burned
    """
    user_id = run_context.user_id or "default"
    now = datetime.now()

    db = SessionLocal()
    try:
        record = Exercise(
            user_id=user_id,
            exercise_type=exercise_type,
            duration_minutes=duration_minutes,
            calories_burned=calories_burned,
            recorded_at=now,
        )
        db.add(record)
        db.commit()

        return (
            f"已记录运动：{exercise_type} {duration_minutes}分钟 | 消耗 {calories_burned:.0f}kcal"
        )
    finally:
        db.close()
