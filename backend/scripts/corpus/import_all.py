"""Unified CLI to validate and import a complete corpus directory.

Orchestrates the full pipeline: validate → import knowledge → import graph → import exercises.

Usage:
    python -m scripts.corpus.import_all data/corpus/math/
    python -m scripts.corpus.import_all data/corpus/math/ --dry-run
    python -m scripts.corpus.import_all data/corpus/math/ --skip-validation
"""

import asyncio
import sys
from pathlib import Path

import structlog

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from scripts.corpus.import_exercises import import_exercises
from scripts.corpus.import_graph import import_graph
from scripts.corpus.import_knowledge import import_chunks
from scripts.corpus.validate_corpus import CorpusValidator

logger = structlog.get_logger()


async def run_pipeline(
    corpus_dir: Path,
    *,
    dry_run: bool = False,
    skip_validation: bool = False,
    batch_size: int = 20,
) -> bool:
    """Run the full corpus import pipeline.

    Steps:
    1. Validate corpus files
    2. Import knowledge chunks → Milvus
    3. Import knowledge graph → Neo4j
    4. Import exercises → Neo4j (linked to knowledge points)

    Returns True if all steps succeeded.
    """
    print("=" * 60)
    print(f"Corpus Import Pipeline: {corpus_dir}")
    print(f"Mode: {'DRY RUN' if dry_run else 'LIVE IMPORT'}")
    print("=" * 60)

    # Step 1: Validation
    if not skip_validation:
        print("\n[1/4] Validating corpus files...")
        validator = CorpusValidator(corpus_dir)
        is_valid = validator.validate_all()
        validator.print_report()
        if not is_valid:
            print("\nAborting: Fix errors before importing.")
            return False
        print("\nValidation passed.")
    else:
        print("\n[1/4] Validation skipped.")

    # Step 2: Knowledge chunks → Milvus
    chunks_file = corpus_dir / "knowledge_chunks.jsonl"
    if chunks_file.exists():
        print("\n[2/4] Importing knowledge chunks → Milvus...")
        result = await import_chunks(chunks_file, batch_size=batch_size, dry_run=dry_run)
        print(f"  Result: {result}")
        if result.get("failed"):
            print("  WARNING: Some chunks failed to import.")
    else:
        print("\n[2/4] No knowledge_chunks.jsonl found, skipping Milvus import.")

    # Step 3: Knowledge graph → Neo4j
    graph_file = corpus_dir / "knowledge_graph.jsonl"
    if graph_file.exists():
        print("\n[3/4] Importing knowledge graph → Neo4j...")
        result = await import_graph(graph_file, dry_run=dry_run)
        print(f"  Result: {result}")
    else:
        print("\n[3/4] No knowledge_graph.jsonl found, skipping graph import.")

    # Step 4: Exercises → Neo4j
    exercises_file = corpus_dir / "exercises.jsonl"
    if exercises_file.exists():
        print("\n[4/4] Importing exercises → Neo4j...")
        result = await import_exercises(exercises_file, dry_run=dry_run)
        print(f"  Result: {result}")
    else:
        print("\n[4/4] No exercises.jsonl found, skipping exercise import.")

    print("\n" + "=" * 60)
    print("Pipeline complete.")
    print("=" * 60)
    return True


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Validate and import a complete corpus")
    parser.add_argument("corpus_dir", type=Path, help="Directory containing JSONL corpus files")
    parser.add_argument("--dry-run", action="store_true", help="Validate and preview without importing")
    parser.add_argument("--skip-validation", action="store_true", help="Skip validation step")
    parser.add_argument("--batch-size", type=int, default=20, help="Embedding batch size for Milvus")
    args = parser.parse_args()

    if not args.corpus_dir.is_dir():
        print(f"Error: Not a directory: {args.corpus_dir}")
        sys.exit(1)

    success = asyncio.run(
        run_pipeline(
            args.corpus_dir,
            dry_run=args.dry_run,
            skip_validation=args.skip_validation,
            batch_size=args.batch_size,
        )
    )
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
