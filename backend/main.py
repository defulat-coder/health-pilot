from contextlib import asynccontextmanager
from datetime import datetime
from typing import Optional

from agno.os import AgentOS
from fastapi import FastAPI, Query
from pydantic import BaseModel, Field
from starlette.requests import Request
from starlette.responses import Response

from agents.coach import coach_agent
from models.database import init_db
from scheduler.push_scheduler import init_scheduler, shutdown_scheduler
from services.apple_health_sync import sync_apple_health_samples as sync_apple_health_samples_service
from services.health_summary import build_health_summary
from services.notifications import list_notifications, mark_notification_read as mark_notification_read_service
from tools.apple_health_analyzer import (
    build_health_dashboard,
    generate_health_report,
    latest_report_context,
    list_health_reports,
)


class AppleHealthSampleInput(BaseModel):
    type: str
    category: str
    unit: str
    value: float | None = None
    source: str = "unknown"
    start_at: datetime
    end_at: datetime
    metadata: dict = Field(default_factory=dict)


class AppleHealthSyncRequest(BaseModel):
    user_id: str = "default"
    samples: list[AppleHealthSampleInput]


class HealthReportRequest(BaseModel):
    user_id: str = "default"
    kind: str = "daily"
    period_start: str = ""
    period_end: str = ""


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
    return list_notifications(user_id=user_id, unread=unread, limit=limit)


@base_app.get("/api/v1/health-summary")
def get_health_summary(user_id: str = "default"):
    return build_health_summary(user_id=user_id)


@base_app.post("/api/v1/apple-health/samples")
def sync_apple_health_samples(payload: AppleHealthSyncRequest):
    return sync_apple_health_samples_service(
        user_id=payload.user_id,
        samples=payload.samples,
    )


@base_app.get("/api/v1/apple-health/dashboard")
def get_apple_health_dashboard(user_id: str = "default"):
    return build_health_dashboard(user_id=user_id)


@base_app.post("/api/v1/apple-health/reports")
def create_apple_health_report(payload: HealthReportRequest):
    return generate_health_report(
        user_id=payload.user_id,
        kind=payload.kind,
        period_start=payload.period_start,
        period_end=payload.period_end,
    )


@base_app.get("/api/v1/apple-health/reports")
def get_apple_health_reports(user_id: str = "default", limit: int = Query(10, le=50)):
    return list_health_reports(user_id=user_id, limit=limit)


@base_app.get("/api/v1/apple-health/reports/latest-context")
def get_latest_apple_health_report_context(user_id: str = "default"):
    return {"user_id": user_id, "context": latest_report_context(user_id=user_id)}


@base_app.post("/api/v1/notifications/{notification_id}/read")
def mark_notification_read(notification_id: int):
    return mark_notification_read_service(notification_id)


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
