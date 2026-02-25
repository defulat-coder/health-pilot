from datetime import datetime
from typing import Optional

from agno.run import RunContext

from models.database import SessionLocal, Weight


def record_weight(
    run_context: RunContext,
    weight_kg: float,
    body_fat_pct: Optional[float] = None,
) -> str:
    """记录用户体重。当用户上报体重、发送体重秤照片或体成分数据时调用。

    Args:
        weight_kg (float): 体重，单位千克
        body_fat_pct (float): 体脂率，可选
    """
    user_id = run_context.user_id or "default"
    now = datetime.now()

    db = SessionLocal()
    try:
        record = Weight(
            user_id=user_id,
            weight_kg=weight_kg,
            body_fat_pct=body_fat_pct,
            recorded_at=now,
        )
        db.add(record)
        db.commit()

        msg = f"已记录体重：{weight_kg:.1f}kg"
        if body_fat_pct is not None:
            msg += f" | 体脂率 {body_fat_pct:.1f}%"
        return msg
    finally:
        db.close()
