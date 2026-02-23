"""Tests for LLM client (unit tests with no external dependencies)."""

from app.services.llm_client import LLMClient


class TestLLMClient:
    def test_init_default_url(self):
        client = LLMClient()
        assert client.base_url == "http://localhost:8080"

    def test_init_custom_url(self):
        client = LLMClient(base_url="http://my-vllm:9000/")
        assert client.base_url == "http://my-vllm:9000"  # trailing slash stripped

    def test_init_custom_url_no_trailing_slash(self):
        client = LLMClient(base_url="http://my-vllm:9000")
        assert client.base_url == "http://my-vllm:9000"
