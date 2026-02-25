from datetime import datetime
from typing import Optional

from agno.run import RunContext

from models.database import SessionLocal, Weight


def record_weight(
    run_context: RunContext,
    weight_kg: float,
    body_fat_pct: Optional[float] = None,
) -> str:
    """Record the user's weight. Call this when the user reports their weight, sends a scale photo, or body composition data.

    Args:
        weight_kg (float): Body weight in kilograms
        body_fat_pct (float): Body fat percentage, optional
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
