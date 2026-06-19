from datetime import datetime

from sqlalchemy import (
    JSON,
    Boolean,
    Column,
    DateTime,
    Float,
    Integer,
    String,
    Text,
    UniqueConstraint,
    create_engine,
)
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from config import settings


class Base(DeclarativeBase):
    pass


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, unique=True, nullable=False, index=True)
    height_cm = Column(Float, nullable=True)
    weight_kg = Column(Float, nullable=True)
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)
    activity_level = Column(String, nullable=True)
    target_weight_kg = Column(Float, nullable=True)
    target_rate_kg_per_week = Column(Float, default=0.5)
    tdee_kcal = Column(Float, nullable=True)
    push_schedule = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Meal(Base):
    __tablename__ = "meals"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    meal_type = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    calories_kcal = Column(Float, nullable=False)
    protein_g = Column(Float, default=0)
    carbs_g = Column(Float, default=0)
    fat_g = Column(Float, default=0)
    recorded_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Weight(Base):
    __tablename__ = "weights"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    weight_kg = Column(Float, nullable=False)
    body_fat_pct = Column(Float, nullable=True)
    recorded_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    exercise_type = Column(String, nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    calories_burned = Column(Float, nullable=False)
    recorded_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    trigger_type = Column(String, nullable=False)
    trigger_name = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    delivered = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class AppleHealthSample(Base):
    __tablename__ = "apple_health_samples"
    __table_args__ = (
        UniqueConstraint(
            "user_id",
            "sample_type",
            "source",
            "start_at",
            "end_at",
            name="uq_apple_health_sample_identity",
        ),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    sample_type = Column(String, nullable=False, index=True)
    category = Column(String, nullable=False, index=True)
    unit = Column(String, nullable=False)
    value = Column(Float, nullable=True)
    source = Column(String, nullable=False, default="unknown")
    start_at = Column(DateTime, nullable=False, index=True)
    end_at = Column(DateTime, nullable=False, index=True)
    sample_metadata = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class HealthAnalysisReport(Base):
    __tablename__ = "health_analysis_reports"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    kind = Column(String, nullable=False, index=True)
    period_start = Column(DateTime, nullable=False, index=True)
    period_end = Column(DateTime, nullable=False, index=True)
    title = Column(String, nullable=False)
    summary = Column(Text, nullable=False)
    metrics = Column(JSON, nullable=False)
    findings = Column(JSON, nullable=False)
    recommendations = Column(JSON, nullable=False)
    risks = Column(JSON, nullable=False)
    coverage = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)


engine = create_engine(settings.database_url)
SessionLocal = sessionmaker(bind=engine)


def init_db():
    Base.metadata.create_all(bind=engine)


def get_db() -> Session:
    db = SessionLocal()
    try:
        return db
    finally:
        pass
