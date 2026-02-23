"""Tests for Sprint 12 — K8s deployment, monitoring, backup, school system integration."""

import json
import os

import yaml

# ── K8s Deployment Configuration ──────────────────────────────


class TestK8sBase:
    """Verify K8s base manifests."""

    _base = os.path.join(
        os.path.dirname(__file__), "..", "..", "..",
        "infrastructure", "k8s", "base",
    )

    def test_namespace_yaml(self) -> None:
        path = os.path.join(self._base, "namespace.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert doc["kind"] == "Namespace"
        assert doc["metadata"]["name"] == "jy-companion"

    def test_backend_deployment(self) -> None:
        path = os.path.join(self._base, "backend-deployment.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert doc["kind"] == "Deployment"
        assert doc["spec"]["replicas"] >= 2
        containers = doc["spec"]["template"]["spec"]["containers"]
        assert len(containers) >= 1
        # Must have liveness and readiness probes
        c = containers[0]
        assert "livenessProbe" in c
        assert "readinessProbe" in c

    def test_backend_service(self) -> None:
        path = os.path.join(self._base, "backend-service.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert doc["kind"] == "Service"
        assert doc["spec"]["ports"][0]["port"] == 8000

    def test_apisix_deployment(self) -> None:
        path = os.path.join(self._base, "apisix-deployment.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert doc["kind"] == "Deployment"

    def test_apisix_service(self) -> None:
        path = os.path.join(self._base, "apisix-service.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert doc["kind"] == "Service"
        assert doc["spec"]["type"] == "LoadBalancer"

    def test_kustomization(self) -> None:
        path = os.path.join(self._base, "kustomization.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert "resources" in doc
        assert len(doc["resources"]) >= 4


class TestK8sProduction:
    """Verify production overlay."""

    _prod = os.path.join(
        os.path.dirname(__file__), "..", "..", "..",
        "infrastructure", "k8s", "overlays", "production",
    )

    def test_hpa(self) -> None:
        path = os.path.join(self._prod, "hpa.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert doc["kind"] == "HorizontalPodAutoscaler"
        assert doc["spec"]["minReplicas"] >= 3
        assert doc["spec"]["maxReplicas"] >= 10

    def test_backup_cronjob(self) -> None:
        path = os.path.join(self._prod, "backup-cronjob.yaml")
        with open(path, encoding="utf-8") as f:
            docs = list(yaml.safe_load_all(f))
        # At least one CronJob (full backup)
        cronjobs = [d for d in docs if d and d.get("kind") == "CronJob"]
        assert len(cronjobs) >= 1

    def test_production_kustomization(self) -> None:
        path = os.path.join(self._prod, "kustomization.yaml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert "resources" in doc or "patchesStrategicMerge" in doc or "patches" in doc


# ── Prometheus + Grafana Monitoring ───────────────────────────


class TestMonitoring:
    """Verify monitoring configuration."""

    _monitoring = os.path.join(
        os.path.dirname(__file__), "..", "..", "..",
        "infrastructure", "monitoring",
    )

    def test_prometheus_config(self) -> None:
        path = os.path.join(self._monitoring, "prometheus", "prometheus.yml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert "scrape_configs" in doc
        job_names = [j["job_name"] for j in doc["scrape_configs"]]
        assert "backend-api" in job_names

    def test_prometheus_alerts(self) -> None:
        path = os.path.join(self._monitoring, "prometheus", "alerts.yml")
        with open(path, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
        assert "groups" in doc
        assert len(doc["groups"]) >= 2

    def test_grafana_dashboard(self) -> None:
        path = os.path.join(self._monitoring, "grafana", "dashboard.json")
        with open(path, encoding="utf-8") as f:
            raw = json.load(f)
        # Handle both wrapped {"dashboard": {...}} and flat formats
        dashboard = raw.get("dashboard", raw)
        assert "panels" in dashboard
        assert len(dashboard["panels"]) >= 5
        assert dashboard.get("title") is not None


# ── School System Integration ─────────────────────────────────


class TestSchoolSystemIntegration:
    """Verify school system integration client."""

    def test_import(self) -> None:
        from app.integrations.school_system import (
            GradeRecord,
            ScheduleItem,
            SchoolSystemClient,
            StudentInfo,
            TeacherInfo,
        )
        assert SchoolSystemClient is not None
        assert StudentInfo is not None
        assert TeacherInfo is not None
        assert ScheduleItem is not None
        assert GradeRecord is not None

    def test_student_info(self) -> None:
        from app.integrations.school_system import StudentInfo
        s = StudentInfo(
            student_id="S2024001",
            name="张三",
            grade="高一",
            class_name="1班",
            gender="男",
            enrollment_year=2024,
        )
        assert s.student_id == "S2024001"
        assert s.name == "张三"
        assert s.grade == "高一"
        assert s.extra == {}

    def test_teacher_info(self) -> None:
        from app.integrations.school_system import TeacherInfo
        t = TeacherInfo(
            teacher_id="T001",
            name="李老师",
            subject="数学",
            classes=["高一1班", "高一2班"],
        )
        assert t.teacher_id == "T001"
        assert t.subject == "数学"
        assert len(t.classes) == 2

    def test_schedule_item(self) -> None:
        from app.integrations.school_system import ScheduleItem
        item = ScheduleItem(
            class_name="高一1班",
            subject="数学",
            teacher="李老师",
            weekday=1,
            period=1,
            start_time="08:00",
            end_time="08:45",
        )
        assert item.weekday == 1
        assert item.period == 1

    def test_grade_record_percentage(self) -> None:
        from app.integrations.school_system import GradeRecord
        g = GradeRecord(
            student_id="S001",
            subject="数学",
            exam_name="期中考试",
            score=85.0,
            full_score=100.0,
        )
        assert g.percentage == 85.0

    def test_grade_record_percentage_zero_full(self) -> None:
        from app.integrations.school_system import GradeRecord
        g = GradeRecord(
            student_id="S001",
            subject="数学",
            exam_name="测试",
            score=0,
            full_score=0,
        )
        assert g.percentage == 0.0

    def test_client_url_construction(self) -> None:
        from app.integrations.school_system import SchoolSystemClient
        client = SchoolSystemClient(
            base_url="http://school.example.com/",
            api_key="test-key",
        )
        assert client._base_url == "http://school.example.com"
        assert client._api_key == "test-key"

    def test_client_headers(self) -> None:
        from app.integrations.school_system import SchoolSystemClient
        client = SchoolSystemClient(
            base_url="http://localhost:8880",
            api_key="my-secret-key",
        )
        headers = client._headers()
        assert headers["Content-Type"] == "application/json"
        assert headers["Authorization"] == "Bearer my-secret-key"

    def test_client_headers_no_key(self) -> None:
        from app.integrations.school_system import SchoolSystemClient
        client = SchoolSystemClient(
            base_url="http://localhost:8880",
            api_key="",
        )
        headers = client._headers()
        assert "Authorization" not in headers
