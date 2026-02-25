from contextlib import asynccontextmanager
from typing import Optional

from agno.os import AgentOS
from fastapi import FastAPI, Query
from starlette.middleware.cors import CORSMiddleware
from starlette.requests import Request
from starlette.responses import Response

from agents.coach import coach_agent
from models.database import Notification, SessionLocal, init_db
from scheduler.push_scheduler import init_scheduler, shutdown_scheduler


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    init_scheduler()
    yield
    shutdown_scheduler()


base_app = FastAPI(title="Health Pilot", lifespan=lifespan)


@base_app.get("/api/v1/notifications")
def get_notifications(
    user_id: str,
    unread: Optional[bool] = Query(None),
    limit: int = Query(20, le=100),
):
    db = SessionLocal()
    try:
        q = db.query(Notification).filter(Notification.user_id == user_id)
        if unread is True:
            q = q.filter(Notification.delivered == False)
        notifications = q.order_by(Notification.created_at.desc()).limit(limit).all()
        return [
            {
                "id": n.id,
                "trigger_type": n.trigger_type,
                "trigger_name": n.trigger_name,
                "content": n.content,
                "delivered": n.delivered,
                "created_at": n.created_at.isoformat() if n.created_at else None,
            }
            for n in notifications
        ]
    finally:
        db.close()


@base_app.post("/api/v1/notifications/{notification_id}/read")
def mark_notification_read(notification_id: int):
    db = SessionLocal()
    try:
        n = db.query(Notification).filter(Notification.id == notification_id).first()
        if n:
            n.delivered = True
            db.commit()
            return {"status": "ok"}
        return {"status": "not_found"}
    finally:
        db.close()


agent_os = AgentOS(
    name="Health Pilot",
    agents=[coach_agent],
    base_app=base_app,
)

app = agent_os.get_app()


@app.middleware("http")
async def cors_middleware(request: Request, call_next):
    origin = request.headers.get("origin", "")

    if request.method == "OPTIONS":
        response = Response(status_code=200)
    else:
        response = await call_next(request)

    if origin:
        response.headers["access-control-allow-origin"] = origin
        response.headers["access-control-allow-credentials"] = "true"
        response.headers["access-control-allow-methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD"
        response.headers["access-control-allow-headers"] = "content-type, authorization, x-requested-with, accept, origin"
        response.headers["access-control-max-age"] = "600"

    return response


if __name__ == "__main__":
    agent_os.serve(app="main:app", port=7777, reload=True)
