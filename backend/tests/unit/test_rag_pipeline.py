"""Tests for RAG pipeline — document chunker (no external deps needed)."""

from app.services.rag_pipeline import DocumentChunker


class TestDocumentChunker:
    def setup_method(self):
        self.chunker = DocumentChunker(chunk_size=100, overlap=20)

    def test_short_text_single_chunk(self):
        text = "Hello world, this is a short text."
        chunks = self.chunker.chunk(text)
        assert len(chunks) == 1
        assert chunks[0] == text

    def test_long_text_multiple_chunks(self):
        text = "A" * 250
        chunks = self.chunker.chunk(text)
        assert len(chunks) > 1
        # Each chunk should be ≤ chunk_size
        for chunk in chunks:
            assert len(chunk) <= 100

    def test_overlap(self):
        text = "ABCDEFGHIJ" * 20  # 200 chars
        chunker = DocumentChunker(chunk_size=50, overlap=10)
        chunks = chunker.chunk(text)
        # With overlap, consecutive chunks share some characters
        assert len(chunks) >= 4

    def test_empty_text(self):
        chunks = self.chunker.chunk("")
        assert len(chunks) == 0 or chunks == [""]

    def test_exact_chunk_size(self):
        text = "X" * 100
        chunks = self.chunker.chunk(text)
        assert len(chunks) == 1
