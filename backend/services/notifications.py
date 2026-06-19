from models.database import Notification, SessionLocal


def list_notifications(
    user_id: str,
    *,
    unread: bool | None = None,
    limit: int = 20,
) -> list[dict[str, object]]:
    """Return notification rows for client polling."""
    db = SessionLocal()
    try:
        query = db.query(Notification).filter(Notification.user_id == user_id)
        if unread is True:
            query = query.filter(Notification.delivered == False)
        notifications = (
            query.order_by(Notification.created_at.desc())
            .limit(limit)
            .all()
        )
        return [
            {
                "id": notification.id,
                "trigger_type": notification.trigger_type,
                "trigger_name": notification.trigger_name,
                "content": notification.content,
                "delivered": notification.delivered,
                "created_at": (
                    notification.created_at.isoformat()
                    if notification.created_at
                    else None
                ),
            }
            for notification in notifications
        ]
    finally:
        db.close()


def mark_notification_read(notification_id: int) -> dict[str, str]:
    """Mark one notification as delivered/read if it exists."""
    db = SessionLocal()
    try:
        notification = (
            db.query(Notification)
            .filter(Notification.id == notification_id)
            .first()
        )
        if not notification:
            return {"status": "not_found"}
        notification.delivered = True
        db.commit()
        return {"status": "ok"}
    finally:
        db.close()
