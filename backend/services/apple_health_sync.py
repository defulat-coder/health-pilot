from datetime import datetime
from typing import Protocol

from sqlalchemy import func

from models.database import AppleHealthSample, SessionLocal


class AppleHealthIncomingSample(Protocol):
    type: str
    category: str
    unit: str
    value: float | None
    source: str
    start_at: datetime
    end_at: datetime
    metadata: dict


def sync_apple_health_samples(
    user_id: str,
    samples: list[AppleHealthIncomingSample],
) -> dict[str, object]:
    """Upsert Apple Health samples by their source and time-window identity."""
    db = SessionLocal()
    inserted = 0
    updated = 0
    try:
        for incoming in samples:
            source = incoming.source or "unknown"
            sample = (
                db.query(AppleHealthSample)
                .filter(
                    AppleHealthSample.user_id == user_id,
                    AppleHealthSample.sample_type == incoming.type,
                    AppleHealthSample.source == source,
                    AppleHealthSample.start_at == incoming.start_at,
                    AppleHealthSample.end_at == incoming.end_at,
                )
                .first()
            )
            if sample:
                sample.category = incoming.category
                sample.unit = incoming.unit
                sample.value = incoming.value
                sample.sample_metadata = incoming.metadata
                sample.updated_at = datetime.utcnow()
                updated += 1
            else:
                db.add(
                    AppleHealthSample(
                        user_id=user_id,
                        sample_type=incoming.type,
                        category=incoming.category,
                        unit=incoming.unit,
                        value=incoming.value,
                        source=source,
                        start_at=incoming.start_at,
                        end_at=incoming.end_at,
                        sample_metadata=incoming.metadata,
                    )
                )
                inserted += 1
        db.commit()
        total = (
            db.query(func.count(AppleHealthSample.id))
            .filter(AppleHealthSample.user_id == user_id)
            .scalar()
            or 0
        )
        return {
            "user_id": user_id,
            "received": len(samples),
            "inserted": inserted,
            "updated": updated,
            "total": total,
            "synced_at": datetime.utcnow().isoformat(),
        }
    finally:
        db.close()
