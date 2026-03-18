import threading
from datetime import datetime

from agno.run import RunContext

from models.database import Exercise, SessionLocal
from scheduler.push_scheduler import check_conditional_triggers


def record_exercise(
    run_context: RunContext,
    exercise_type: str,
    duration_minutes: int,
    calories_burned: float,
) -> str:
    """记录运动。当用户上报运动、发送健身App截图或描述训练内容时调用。

    Args:
        exercise_type (str): 运动类型，如 "跑步"、"游泳"、"力量训练"
        duration_minutes (int): 运动时长，单位分钟
        calories_burned (float): 估算消耗热量，单位千卡
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

        # 异步触发条件推送检查
        threading.Thread(target=check_conditional_triggers, args=(user_id,)).start()

        return (
            f"已记录运动：{exercise_type} {duration_minutes}分钟 | 消耗 {calories_burned:.0f}kcal"
        )
    finally:
        db.close()
