"""Tests for classroom service — doubt detection and text similarity."""

from app.models.classroom import SessionStatus
from app.services.classroom_service import _text_similarity


class TestTextSimilarity:
    def test_identical(self):
        assert _text_similarity("abc", "abc") == 1.0

    def test_no_overlap(self):
        assert _text_similarity("abc", "def") == 0.0

    def test_partial_overlap(self):
        sim = _text_similarity("abcd", "cdef")
        assert 0.0 < sim < 1.0

    def test_empty_string(self):
        assert _text_similarity("", "abc") == 0.0
        assert _text_similarity("abc", "") == 0.0
        assert _text_similarity("", "") == 0.0

    def test_chinese_text(self):
        sim = _text_similarity("这道题怎么做", "这道题怎么解")
        assert sim > 0.5


class TestSessionStatus:
    def test_status_values(self):
        assert SessionStatus.UPLOADING == "uploading"
        assert SessionStatus.TRANSCRIBING == "transcribing"
        assert SessionStatus.SUMMARIZING == "summarizing"
        assert SessionStatus.COMPLETED == "completed"
        assert SessionStatus.FAILED == "failed"


class TestASRClient:
    def test_init_default_url(self):
        from app.services.asr_client import ASRClient

        client = ASRClient()
        assert client.base_url == "http://localhost:8867"

    def test_init_custom_url(self):
        from app.services.asr_client import ASRClient

        client = ASRClient(base_url="http://my-asr:9000/")
        assert client.base_url == "http://my-asr:9000"


class TestASRResult:
    def test_result_creation(self):
        from app.services.asr_client import ASRResult

        result = ASRResult(text="你好世界", segments=[{"start": 0.0, "end": 1.5, "text": "你好世界"}])
        assert result.text == "你好世界"
        assert len(result.segments) == 1

    def test_empty_segments(self):
        from app.services.asr_client import ASRResult

        result = ASRResult(text="test")
        assert result.segments == []


class TestMinIOClient:
    def test_init(self):
        from app.services.minio_client import MinIOClient

        client = MinIOClient()
        assert client.bucket == "jy-companion"
        assert "localhost" in client.endpoint


class TestClassroomAgent:
    def test_capabilities(self):
        from app.agents.classroom_agent import ClassroomAgent
        from app.models.conversation import AgentType

        agent = ClassroomAgent()
        assert agent.get_agent_type() == AgentType.CLASSROOM
        caps = agent.get_capabilities()
        assert "classroom_review" in caps
        assert "study_plan_generation" in caps
