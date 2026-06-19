from datetime import datetime, timedelta
import unittest

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool

import models.database as database
from agents.coach import get_user_instructions
from main import base_app
from services.apple_health_sync import sync_apple_health_samples
from services.health_summary import build_health_summary
from services.notifications import list_notifications, mark_notification_read


class RunContextStub:
    def __init__(self, user_id: str):
        self.user_id = user_id


class AppleHealthSampleStub:
    def __init__(
        self,
        sample_type: str,
        category: str,
        unit: str,
        value: float,
        source: str,
        start_at: datetime,
        end_at: datetime,
        metadata: dict | None = None,
    ):
        self.type = sample_type
        self.category = category
        self.unit = unit
        self.value = value
        self.source = source
        self.start_at = start_at
        self.end_at = end_at
        self.metadata = metadata or {}


class AppleHealthAPITests(unittest.TestCase):
    def setUp(self):
        engine = create_engine(
            "sqlite://",
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
        database.engine = engine
        database.SessionLocal.configure(bind=engine)
        database.Base.metadata.drop_all(bind=engine)
        database.Base.metadata.create_all(bind=engine)
        self.engine = engine
        self.client = TestClient(base_app)

    def tearDown(self):
        self.client.close()
        self.engine.dispose()

    def test_apple_health_sync_is_idempotent_and_dashboard_aggregates_core_metrics(self):
        now = datetime(2026, 6, 19, 8, 0, 0)
        payload = {
            "user_id": "default",
            "samples": [
                {
                    "type": "step_count",
                    "category": "activity",
                    "unit": "count",
                    "value": 4300,
                    "source": "com.apple.Health",
                    "start_at": now.isoformat(),
                    "end_at": (now + timedelta(hours=1)).isoformat(),
                    "metadata": {},
                },
                {
                    "type": "active_energy_burned",
                    "category": "activity",
                    "unit": "kcal",
                    "value": 220,
                    "source": "com.apple.Health",
                    "start_at": now.isoformat(),
                    "end_at": (now + timedelta(hours=1)).isoformat(),
                    "metadata": {},
                },
                {
                    "type": "sleep_analysis",
                    "category": "sleep",
                    "unit": "min",
                    "value": 420,
                    "source": "com.apple.Health",
                    "start_at": (now - timedelta(hours=8)).isoformat(),
                    "end_at": (now - timedelta(hours=1)).isoformat(),
                    "metadata": {"stage": "asleep"},
                },
                {
                    "type": "resting_heart_rate",
                    "category": "vitals",
                    "unit": "count/min",
                    "value": 62,
                    "source": "com.apple.Health",
                    "start_at": now.isoformat(),
                    "end_at": now.isoformat(),
                    "metadata": {},
                },
                {
                    "type": "body_mass",
                    "category": "body",
                    "unit": "kg",
                    "value": 72.4,
                    "source": "com.apple.Health",
                    "start_at": now.isoformat(),
                    "end_at": now.isoformat(),
                    "metadata": {},
                },
            ],
        }

        first = self.client.post("/api/v1/apple-health/samples", json=payload)
        second = self.client.post("/api/v1/apple-health/samples", json=payload)

        self.assertEqual(first.status_code, 200)
        self.assertEqual(first.json()["inserted"], 5)
        self.assertEqual(second.status_code, 200)
        self.assertEqual(second.json()["inserted"], 0)
        self.assertEqual(second.json()["updated"], 5)

        dashboard = self.client.get("/api/v1/apple-health/dashboard", params={"user_id": "default"})

        self.assertEqual(dashboard.status_code, 200)
        body = dashboard.json()
        self.assertEqual(body["connection"]["sample_count"], 5)
        self.assertEqual(body["metrics"]["activity"]["steps"], 4300)
        self.assertEqual(body["metrics"]["activity"]["active_energy_kcal"], 220)
        self.assertEqual(body["metrics"]["sleep"]["asleep_minutes"], 420)
        self.assertEqual(body["metrics"]["vitals"]["resting_heart_rate"], 62)
        self.assertEqual(body["metrics"]["body"]["weight_kg"], 72.4)

    def test_apple_health_sync_service_upserts_by_sample_identity(self):
        now = datetime(2026, 6, 19, 8, 0, 0)
        sample = AppleHealthSampleStub(
            sample_type="step_count",
            category="activity",
            unit="count",
            value=4300,
            source="com.apple.Health",
            start_at=now,
            end_at=now + timedelta(hours=1),
        )

        first = sync_apple_health_samples(user_id="default", samples=[sample])
        sample.value = 5200
        second = sync_apple_health_samples(user_id="default", samples=[sample])

        self.assertEqual(first["inserted"], 1)
        self.assertEqual(first["updated"], 0)
        self.assertEqual(second["inserted"], 0)
        self.assertEqual(second["updated"], 1)
        self.assertEqual(second["total"], 1)

        db = database.SessionLocal()
        try:
            saved = db.query(database.AppleHealthSample).first()
            self.assertEqual(saved.value, 5200)
        finally:
            db.close()

    def test_apple_health_report_generation_and_latest_context_feed_chat(self):
        now = datetime(2026, 6, 19, 8, 0, 0)
        sync = self.client.post(
            "/api/v1/apple-health/samples",
            json={
                "user_id": "default",
                "samples": [
                    {
                        "type": "step_count",
                        "category": "activity",
                        "unit": "count",
                        "value": 9000,
                        "source": "com.apple.Health",
                        "start_at": now.isoformat(),
                        "end_at": (now + timedelta(hours=12)).isoformat(),
                        "metadata": {},
                    },
                    {
                        "type": "sleep_analysis",
                        "category": "sleep",
                        "unit": "min",
                        "value": 360,
                        "source": "com.apple.Health",
                        "start_at": (now - timedelta(hours=7)).isoformat(),
                        "end_at": (now - timedelta(hours=1)).isoformat(),
                        "metadata": {"stage": "asleep"},
                    },
                ],
            },
        )
        self.assertEqual(sync.status_code, 200)

        report_response = self.client.post(
            "/api/v1/apple-health/reports",
            json={
                "user_id": "default",
                "kind": "daily",
                "period_start": "2026-06-19",
                "period_end": "2026-06-19",
            },
        )

        self.assertEqual(report_response.status_code, 200)
        report = report_response.json()
        self.assertEqual(report["kind"], "daily")
        self.assertEqual(report["title"], "Apple Health 日报")
        self.assertTrue(any("步数" in finding for finding in report["findings"]))
        self.assertTrue(any("睡眠" in recommendation for recommendation in report["recommendations"]))
        self.assertEqual(report["coverage"]["activity"], "present")
        self.assertEqual(report["coverage"]["sleep"], "present")

        latest = self.client.get("/api/v1/apple-health/reports/latest-context", params={"user_id": "default"})
        self.assertEqual(latest.status_code, 200)
        self.assertIn("Apple Health 日报", latest.json()["context"])
        self.assertIn("非医疗诊断", latest.json()["context"])

        instructions = get_user_instructions(RunContextStub("default"))
        self.assertIn("最新 Apple Health 分析报告", instructions)
        self.assertIn("Apple Health 日报", instructions)

    def test_health_summary_aggregates_profile_today_activity_and_notifications(self):
        now = datetime(2026, 6, 19, 8, 0, 0)
        db = database.SessionLocal()
        try:
            db.add(
                database.UserProfile(
                    user_id="default",
                    height_cm=172,
                    weight_kg=80,
                    age=32,
                    gender="male",
                    activity_level="light",
                    target_weight_kg=72,
                    target_rate_kg_per_week=0.5,
                    tdee_kcal=2400,
                )
            )
            db.add(
                database.Meal(
                    user_id="default",
                    meal_type="breakfast",
                    description="燕麦和鸡蛋",
                    calories_kcal=420,
                    protein_g=28,
                    carbs_g=46,
                    fat_g=14,
                    recorded_at=now,
                )
            )
            db.add(
                database.Exercise(
                    user_id="default",
                    exercise_type="walk",
                    duration_minutes=35,
                    calories_burned=180,
                    recorded_at=now,
                )
            )
            db.add(
                database.Notification(
                    user_id="default",
                    trigger_type="conditional",
                    trigger_name="protein_gap",
                    content="晚餐可以补一点蛋白质，这是估算提醒。",
                    delivered=False,
                    created_at=now,
                )
            )
            db.commit()
        finally:
            db.close()

        summary = build_health_summary(user_id="default", today=now.date())

        self.assertEqual(summary["profile"]["daily_calorie_target_kcal"], 1850)
        self.assertEqual(summary["today"]["calories_consumed_kcal"], 420)
        self.assertEqual(summary["today"]["remaining_calories_kcal"], 1610)
        self.assertEqual(summary["today"]["protein_target_g"], 128)
        self.assertEqual(summary["today"]["exercise_minutes"], 35)
        self.assertEqual(summary["today"]["meal_count"], 1)
        self.assertEqual(summary["notifications"][0]["trigger_name"], "protein_gap")

    def test_notification_service_lists_unread_and_marks_read(self):
        now = datetime(2026, 6, 19, 8, 0, 0)
        db = database.SessionLocal()
        try:
            db.add(
                database.Notification(
                    user_id="default",
                    trigger_type="scheduled",
                    trigger_name="breakfast",
                    content="早餐记录提醒",
                    delivered=False,
                    created_at=now,
                )
            )
            db.add(
                database.Notification(
                    user_id="default",
                    trigger_type="scheduled",
                    trigger_name="old",
                    content="已读提醒",
                    delivered=True,
                    created_at=now - timedelta(hours=1),
                )
            )
            db.commit()
            unread_id = (
                db.query(database.Notification)
                .filter(database.Notification.trigger_name == "breakfast")
                .first()
                .id
            )
        finally:
            db.close()

        unread = list_notifications(user_id="default", unread=True)
        self.assertEqual([notification["trigger_name"] for notification in unread], ["breakfast"])

        result = mark_notification_read(unread_id)
        self.assertEqual(result["status"], "ok")
        self.assertEqual(list_notifications(user_id="default", unread=True), [])


if __name__ == "__main__":
    unittest.main()
