from datetime import datetime, time
from typing import Any

from models.database import AppleHealthSample, HealthAnalysisReport, SessionLocal


METRIC_FAMILIES = ("activity", "sleep", "vitals", "body")


def parse_report_date(value: str) -> datetime:
    parsed = datetime.fromisoformat(value)
    return datetime.combine(parsed.date(), time.min)


def build_health_dashboard(user_id: str = "default") -> dict[str, Any]:
    db = SessionLocal()
    try:
        samples = (
            db.query(AppleHealthSample)
            .filter(AppleHealthSample.user_id == user_id)
            .order_by(AppleHealthSample.start_at.asc())
            .all()
        )
        metrics = summarize_samples(samples)
        last_sync = max((sample.updated_at or sample.created_at for sample in samples), default=None)

        return {
            "user_id": user_id,
            "connection": {
                "status": "connected" if samples else "not_connected",
                "sample_count": len(samples),
                "last_sync_at": last_sync.isoformat() if last_sync else None,
            },
            "metrics": metrics,
            "coverage": build_coverage(metrics),
        }
    finally:
        db.close()


def generate_health_report(
    user_id: str = "default",
    kind: str = "daily",
    period_start: str = "",
    period_end: str = "",
) -> dict[str, Any]:
    start = parse_report_date(period_start) if period_start else datetime.combine(datetime.now().date(), time.min)
    end = parse_report_date(period_end) if period_end else start
    end = datetime.combine(end.date(), time.max)

    db = SessionLocal()
    try:
        samples = (
            db.query(AppleHealthSample)
            .filter(
                AppleHealthSample.user_id == user_id,
                AppleHealthSample.start_at <= end,
                AppleHealthSample.end_at >= start,
            )
            .order_by(AppleHealthSample.start_at.asc())
            .all()
        )
        metrics = summarize_samples(samples)
        coverage = build_coverage(metrics)
        findings = build_findings(metrics, coverage)
        recommendations = build_recommendations(metrics, coverage)
        risks = build_risks(metrics, coverage)
        title = "Apple Health 日报" if kind == "daily" else "Apple Health 周报"
        summary = build_summary(metrics, coverage)

        report = HealthAnalysisReport(
            user_id=user_id,
            kind=kind,
            period_start=start,
            period_end=end,
            title=title,
            summary=summary,
            metrics=metrics,
            findings=findings,
            recommendations=recommendations,
            risks=risks,
            coverage=coverage,
        )
        db.add(report)
        db.commit()
        db.refresh(report)
        return serialize_report(report)
    finally:
        db.close()


def list_health_reports(user_id: str = "default", limit: int = 10) -> list[dict[str, Any]]:
    db = SessionLocal()
    try:
        reports = (
            db.query(HealthAnalysisReport)
            .filter(HealthAnalysisReport.user_id == user_id)
            .order_by(HealthAnalysisReport.created_at.desc())
            .limit(limit)
            .all()
        )
        return [serialize_report(report) for report in reports]
    finally:
        db.close()


def latest_report_context(user_id: str = "default") -> str:
    db = SessionLocal()
    try:
        report = (
            db.query(HealthAnalysisReport)
            .filter(HealthAnalysisReport.user_id == user_id)
            .order_by(HealthAnalysisReport.created_at.desc())
            .first()
        )
        if not report:
            return ""

        findings = "；".join(report.findings[:3])
        recommendations = "；".join(report.recommendations[:3])
        coverage = "，".join(f"{key}:{value}" for key, value in report.coverage.items())
        return (
            "## 最新 Apple Health 分析报告\n"
            f"- 标题：{report.title}\n"
            f"- 周期：{report.period_start.date().isoformat()} ~ {report.period_end.date().isoformat()}\n"
            f"- 摘要：{report.summary}\n"
            f"- 发现：{findings or '暂无明显趋势'}\n"
            f"- 建议：{recommendations or '继续补充数据后再分析'}\n"
            f"- 数据覆盖：{coverage}\n"
            "- 安全边界：以上是基于 Apple Health 和 Health Pilot 记录的健康管理分析，非医疗诊断。"
        )
    finally:
        db.close()


def summarize_samples(samples: list[AppleHealthSample]) -> dict[str, Any]:
    latest_by_type: dict[str, AppleHealthSample] = {}
    totals = {
        "step_count": 0.0,
        "active_energy_burned": 0.0,
        "apple_exercise_time": 0.0,
        "sleep_analysis": 0.0,
    }
    workouts = 0
    heart_rates: list[float] = []

    for sample in samples:
        if sample.value is not None and sample.sample_type in totals:
            totals[sample.sample_type] += sample.value
        if sample.sample_type == "workout":
            workouts += 1
        if sample.sample_type == "heart_rate" and sample.value is not None:
            heart_rates.append(sample.value)
        current = latest_by_type.get(sample.sample_type)
        if current is None or sample.end_at >= current.end_at:
            latest_by_type[sample.sample_type] = sample

    resting = latest_by_type.get("resting_heart_rate")
    weight = latest_by_type.get("body_mass")
    body_fat = latest_by_type.get("body_fat_percentage")
    height = latest_by_type.get("height")

    return {
        "activity": {
            "steps": int(totals["step_count"]),
            "active_energy_kcal": round(totals["active_energy_burned"], 1),
            "exercise_minutes": int(totals["apple_exercise_time"]),
            "workouts": workouts,
        },
        "sleep": {
            "asleep_minutes": int(totals["sleep_analysis"]),
        },
        "vitals": {
            "heart_rate_avg": round(sum(heart_rates) / len(heart_rates), 1) if heart_rates else None,
            "resting_heart_rate": resting.value if resting else None,
        },
        "body": {
            "weight_kg": weight.value if weight else None,
            "body_fat_pct": body_fat.value if body_fat else None,
            "height_cm": height.value if height else None,
        },
    }


def build_coverage(metrics: dict[str, Any]) -> dict[str, str]:
    return {
        "activity": "present" if metrics["activity"]["steps"] or metrics["activity"]["active_energy_kcal"] else "missing",
        "sleep": "present" if metrics["sleep"]["asleep_minutes"] else "missing",
        "vitals": "present" if metrics["vitals"]["heart_rate_avg"] or metrics["vitals"]["resting_heart_rate"] else "missing",
        "body": "present" if metrics["body"]["weight_kg"] or metrics["body"]["body_fat_pct"] else "missing",
    }


def build_summary(metrics: dict[str, Any], coverage: dict[str, str]) -> str:
    present = [family for family, state in coverage.items() if state == "present"]
    if not present:
        return "当前 Apple Health 数据不足，建议先完成授权并同步最近数据。"
    steps = metrics["activity"]["steps"]
    sleep_hours = metrics["sleep"]["asleep_minutes"] / 60
    return f"已读取 {len(present)} 类 Apple Health 数据；步数 {steps}，睡眠约 {sleep_hours:.1f} 小时。"


def build_findings(metrics: dict[str, Any], coverage: dict[str, str]) -> list[str]:
    findings: list[str] = []
    steps = metrics["activity"]["steps"]
    if coverage["activity"] == "present":
        findings.append(f"步数为 {steps} 步，活动能量约 {metrics['activity']['active_energy_kcal']:.0f} kcal。")
    if coverage["sleep"] == "present":
        findings.append(f"睡眠记录约 {metrics['sleep']['asleep_minutes'] // 60} 小时 {metrics['sleep']['asleep_minutes'] % 60} 分钟。")
    if coverage["vitals"] == "present" and metrics["vitals"]["resting_heart_rate"]:
        findings.append(f"静息心率约 {metrics['vitals']['resting_heart_rate']:.0f} 次/分钟。")
    if coverage["body"] == "present" and metrics["body"]["weight_kg"]:
        findings.append(f"最近体重记录为 {metrics['body']['weight_kg']:.1f} kg。")
    return findings


def build_recommendations(metrics: dict[str, Any], coverage: dict[str, str]) -> list[str]:
    recommendations: list[str] = []
    if coverage["activity"] == "present" and metrics["activity"]["steps"] < 7000:
        recommendations.append("今天活动量偏低，可以安排一次 20 分钟轻快步行。")
    elif coverage["activity"] == "present":
        recommendations.append("活动量基础不错，晚间优先保证恢复和补水。")
    if coverage["sleep"] == "present" and metrics["sleep"]["asleep_minutes"] < 420:
        recommendations.append("睡眠不足 7 小时，今晚建议提前进入睡前放松流程。")
    elif coverage["sleep"] == "present":
        recommendations.append("睡眠时长接近目标，继续保持稳定作息。")
    for family in METRIC_FAMILIES:
        if coverage[family] == "missing":
            recommendations.append(f"{family} 数据缺失，报告相关建议会保持保守。")
    return recommendations[:5]


def build_risks(metrics: dict[str, Any], coverage: dict[str, str]) -> list[str]:
    risks = []
    if coverage["vitals"] == "present" and metrics["vitals"]["resting_heart_rate"] and metrics["vitals"]["resting_heart_rate"] > 90:
        risks.append("静息心率偏高趋势需要结合身体状态观察，如有不适请咨询医生。")
    if any(state == "missing" for state in coverage.values()):
        risks.append("部分 Apple Health 数据缺失，分析结论只适用于已同步数据。")
    return risks


def serialize_report(report: HealthAnalysisReport) -> dict[str, Any]:
    return {
        "id": report.id,
        "user_id": report.user_id,
        "kind": report.kind,
        "period_start": report.period_start.date().isoformat(),
        "period_end": report.period_end.date().isoformat(),
        "title": report.title,
        "summary": report.summary,
        "metrics": report.metrics,
        "findings": report.findings,
        "recommendations": report.recommendations,
        "risks": report.risks,
        "coverage": report.coverage,
        "created_at": report.created_at.isoformat() if report.created_at else None,
    }
