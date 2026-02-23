"""School educational system integration — sync students, classes, grades, schedules.

Supports:
  - Student/Teacher roster sync from school admin system
  - Class schedule import (for classroom agent context)
  - Grade data sync (for academic agent personalization)
  - Attendance data (for health agent correlations)
"""

import structlog

from app.config.settings import get_settings

logger = structlog.get_logger()


class StudentInfo:
    """Student record from school system."""

    def __init__(
        self,
        student_id: str,
        name: str,
        grade: str,
        class_name: str,
        gender: str | None = None,
        enrollment_year: int | None = None,
        homeroom_teacher: str | None = None,
        extra: dict | None = None,
    ):
        self.student_id = student_id
        self.name = name
        self.grade = grade
        self.class_name = class_name
        self.gender = gender
        self.enrollment_year = enrollment_year
        self.homeroom_teacher = homeroom_teacher
        self.extra = extra or {}


class TeacherInfo:
    """Teacher record from school system."""

    def __init__(
        self,
        teacher_id: str,
        name: str,
        subject: str,
        classes: list[str] | None = None,
        title: str | None = None,
        extra: dict | None = None,
    ):
        self.teacher_id = teacher_id
        self.name = name
        self.subject = subject
        self.classes = classes or []
        self.title = title
        self.extra = extra or {}


class ScheduleItem:
    """Single class schedule entry."""

    def __init__(
        self,
        class_name: str,
        subject: str,
        teacher: str,
        weekday: int,
        period: int,
        start_time: str,
        end_time: str,
    ):
        self.class_name = class_name
        self.subject = subject
        self.teacher = teacher
        self.weekday = weekday  # 1=Monday, 7=Sunday
        self.period = period
        self.start_time = start_time
        self.end_time = end_time


class GradeRecord:
    """Student grade/score from school system."""

    def __init__(
        self,
        student_id: str,
        subject: str,
        exam_name: str,
        score: float,
        full_score: float = 100.0,
        rank_in_class: int | None = None,
        semester: str | None = None,
    ):
        self.student_id = student_id
        self.subject = subject
        self.exam_name = exam_name
        self.score = score
        self.full_score = full_score
        self.rank_in_class = rank_in_class
        self.semester = semester

    @property
    def percentage(self) -> float:
        """Score as percentage."""
        if self.full_score == 0:
            return 0.0
        return (self.score / self.full_score) * 100


class SchoolSystemClient:
    """Client for school educational administration system.

    Integrates with common Chinese school management platforms
    via REST API or database sync.
    """

    def __init__(self, base_url: str | None = None, api_key: str | None = None) -> None:
        settings = get_settings()
        self._base_url = (
            base_url
            or getattr(settings, "school_system_url", "http://localhost:8880")
        ).rstrip("/")
        self._api_key = api_key or getattr(settings, "school_system_api_key", "")

    def _headers(self) -> dict:
        """Build request headers with API key."""
        headers = {"Content-Type": "application/json"}
        if self._api_key:
            headers["Authorization"] = f"Bearer {self._api_key}"
        return headers

    async def get_students(
        self, grade: str | None = None, class_name: str | None = None,
    ) -> list[StudentInfo]:
        """Fetch student roster from school system."""
        import httpx

        params: dict[str, str] = {}
        if grade:
            params["grade"] = grade
        if class_name:
            params["class"] = class_name

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.get(
                    f"{self._base_url}/api/students",
                    params=params,
                    headers=self._headers(),
                )
                resp.raise_for_status()
                data = resp.json()

            return [
                StudentInfo(
                    student_id=s["id"],
                    name=s["name"],
                    grade=s.get("grade", ""),
                    class_name=s.get("class_name", ""),
                    gender=s.get("gender"),
                    enrollment_year=s.get("enrollment_year"),
                    homeroom_teacher=s.get("homeroom_teacher"),
                )
                for s in data.get("students", [])
            ]
        except Exception:
            logger.exception("school_system.get_students_failed")
            return []

    async def get_teachers(self, subject: str | None = None) -> list[TeacherInfo]:
        """Fetch teacher roster from school system."""
        import httpx

        params: dict[str, str] = {}
        if subject:
            params["subject"] = subject

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.get(
                    f"{self._base_url}/api/teachers",
                    params=params,
                    headers=self._headers(),
                )
                resp.raise_for_status()
                data = resp.json()

            return [
                TeacherInfo(
                    teacher_id=t["id"],
                    name=t["name"],
                    subject=t.get("subject", ""),
                    classes=t.get("classes", []),
                    title=t.get("title"),
                )
                for t in data.get("teachers", [])
            ]
        except Exception:
            logger.exception("school_system.get_teachers_failed")
            return []

    async def get_schedule(self, class_name: str) -> list[ScheduleItem]:
        """Fetch class schedule from school system."""
        import httpx

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.get(
                    f"{self._base_url}/api/schedules/{class_name}",
                    headers=self._headers(),
                )
                resp.raise_for_status()
                data = resp.json()

            return [
                ScheduleItem(
                    class_name=class_name,
                    subject=s["subject"],
                    teacher=s.get("teacher", ""),
                    weekday=s["weekday"],
                    period=s["period"],
                    start_time=s.get("start_time", ""),
                    end_time=s.get("end_time", ""),
                )
                for s in data.get("schedule", [])
            ]
        except Exception:
            logger.exception("school_system.get_schedule_failed")
            return []

    async def get_grades(
        self, student_id: str, semester: str | None = None,
    ) -> list[GradeRecord]:
        """Fetch student grades from school system."""
        import httpx

        params: dict[str, str] = {}
        if semester:
            params["semester"] = semester

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.get(
                    f"{self._base_url}/api/students/{student_id}/grades",
                    params=params,
                    headers=self._headers(),
                )
                resp.raise_for_status()
                data = resp.json()

            return [
                GradeRecord(
                    student_id=student_id,
                    subject=g["subject"],
                    exam_name=g.get("exam_name", ""),
                    score=g["score"],
                    full_score=g.get("full_score", 100.0),
                    rank_in_class=g.get("rank_in_class"),
                    semester=g.get("semester"),
                )
                for g in data.get("grades", [])
            ]
        except Exception:
            logger.exception("school_system.get_grades_failed")
            return []

    async def health_check(self) -> bool:
        """Check school system connectivity."""
        import httpx

        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(
                    f"{self._base_url}/health",
                    headers=self._headers(),
                )
                return resp.status_code == 200
        except Exception:
            return False
