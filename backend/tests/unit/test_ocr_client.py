"""Tests for OCR client (unit tests, no external deps)."""

from app.services.ocr_client import OCRClient


class TestOCRClient:
    def test_init_default_url(self):
        client = OCRClient()
        assert client.base_url == "http://localhost:8866"

    def test_init_custom_url(self):
        client = OCRClient(base_url="http://my-ocr:9000/")
        assert client.base_url == "http://my-ocr:9000"
