"""Import knowledge chunks into Milvus vector store.

Reads JSONL files containing knowledge chunks, generates embeddings via
the embedding service, and inserts them into Milvus for semantic search.

Usage:
    python -m scripts.corpus.import_knowledge data/corpus/math/knowledge_chunks.jsonl
    python -m scripts.corpus.import_knowledge data/corpus/math/knowledge_chunks.jsonl --batch-size 10 --dry-run
"""

import asyncio
import json
import sys
import uuid
from pathlib import Path

import structlog

# Add backend root to sys.path so app modules are importable
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

logger = structlog.get_logger()


def load_chunks(filepath: Path) -> list[dict]:
    """Load knowledge chunks from a JSONL file."""
    chunks = []
    with open(filepath, encoding="utf-8") as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
                # Validate required fields
                for field in ("subject", "chapter", "content"):
                    if field not in item:
                        raise ValueError(f"Missing required field: {field}")
                if "id" not in item:
                    item["id"] = f"{item['subject']}-{uuid.uuid4().hex[:8]}"
                if "source" not in item:
                    item["source"] = ""
                chunks.append(item)
            except (json.JSONDecodeError, ValueError) as e:
                logger.warning("skip_invalid_line", lineno=lineno, error=str(e))
    return chunks


async def import_chunks(
    filepath: Path,
    *,
    batch_size: int = 20,
    dry_run: bool = False,
) -> dict:
    """Import knowledge chunks from JSONL into Milvus.

    Returns:
        Summary dict with counts of imported/skipped/failed items.
    """
    chunks = load_chunks(filepath)
    if not chunks:
        logger.error("no_chunks_loaded", filepath=str(filepath))
        return {"total": 0, "imported": 0, "failed": 0}

    logger.info("chunks_loaded", total=len(chunks), filepath=str(filepath))

    if dry_run:
        logger.info("dry_run_mode", msg="Skipping embedding and Milvus insert")
        for c in chunks:
            logger.info(
                "chunk_preview",
                id=c["id"],
                subject=c["subject"],
                chapter=c["chapter"],
                content_len=len(c["content"]),
            )
        return {"total": len(chunks), "imported": 0, "failed": 0, "dry_run": True}

    # Lazy import to avoid requiring service dependencies for dry-run
    from app.config.settings import get_settings
    from app.services.embedding_service import EmbeddingService
    from app.services.milvus_client import MilvusKnowledgeStore, connect_milvus

    settings = get_settings()
    connect_milvus()
    store = MilvusKnowledgeStore()
    embedder = EmbeddingService()

    imported = 0
    failed = 0

    # Process in batches
    for i in range(0, len(chunks), batch_size):
        batch = chunks[i : i + batch_size]
        texts = [c["content"] for c in batch]

        try:
            embeddings = await embedder.embed(texts)
        except Exception as e:
            logger.error("embedding_failed", batch_start=i, error=str(e))
            failed += len(batch)
            continue

        ids = [c["id"] for c in batch]
        contents = texts
        subjects = [c["subject"] for c in batch]
        chapters = [c["chapter"] for c in batch]
        sources = [c.get("source", "") for c in batch]

        try:
            count = await store.insert(ids, embeddings, contents, subjects, chapters, sources)
            imported += count
            logger.info("batch_imported", batch_start=i, count=count)
        except Exception as e:
            logger.error("milvus_insert_failed", batch_start=i, error=str(e))
            failed += len(batch)

    summary = {"total": len(chunks), "imported": imported, "failed": failed}
    logger.info("import_complete", **summary)
    return summary


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Import knowledge chunks into Milvus")
    parser.add_argument("filepath", type=Path, help="Path to JSONL file with knowledge chunks")
    parser.add_argument("--batch-size", type=int, default=20, help="Embedding batch size")
    parser.add_argument("--dry-run", action="store_true", help="Validate without importing")
    args = parser.parse_args()

    if not args.filepath.exists():
        print(f"Error: File not found: {args.filepath}")
        sys.exit(1)

    result = asyncio.run(import_chunks(args.filepath, batch_size=args.batch_size, dry_run=args.dry_run))
    if result.get("failed"):
        sys.exit(1)


if __name__ == "__main__":
    main()
