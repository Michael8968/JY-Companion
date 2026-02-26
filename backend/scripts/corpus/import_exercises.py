"""Import exercises into Neo4j as Exercise nodes linked to KnowledgePoints.

Reads JSONL files containing exercises and attaches them to the corresponding
KnowledgePoint nodes via HAS_EXERCISE edges.

Usage:
    python -m scripts.corpus.import_exercises data/corpus/math/exercises.jsonl
    python -m scripts.corpus.import_exercises data/corpus/math/exercises.jsonl --dry-run
"""

import asyncio
import json
import sys
import uuid
from pathlib import Path

import structlog

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

logger = structlog.get_logger()


def load_exercises(filepath: Path) -> list[dict]:
    """Load exercises from JSONL file."""
    exercises = []
    with open(filepath, encoding="utf-8") as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
                for field in ("knowledge_point", "content", "answer"):
                    if field not in item:
                        raise ValueError(f"Missing required field: {field}")
                if "id" not in item:
                    item["id"] = f"ex-{uuid.uuid4().hex[:8]}"
                exercises.append(item)
            except (json.JSONDecodeError, ValueError) as e:
                logger.warning("skip_invalid_line", lineno=lineno, error=str(e))
    return exercises


async def import_exercises(filepath: Path, *, dry_run: bool = False) -> dict:
    """Import exercises from JSONL into Neo4j."""
    exercises = load_exercises(filepath)
    if not exercises:
        logger.error("no_exercises_loaded", filepath=str(filepath))
        return {"total": 0, "imported": 0}

    logger.info("exercises_loaded", total=len(exercises), filepath=str(filepath))

    if dry_run:
        for ex in exercises:
            logger.info(
                "exercise_preview",
                id=ex["id"],
                knowledge_point=ex["knowledge_point"],
                type=ex.get("type", "?"),
                difficulty=ex.get("difficulty", "?"),
            )
        return {"total": len(exercises), "imported": 0, "dry_run": True}

    from app.services.neo4j_client import KnowledgeGraphClient

    client = KnowledgeGraphClient()
    imported = 0
    skipped = 0

    try:
        async with client.driver.session() as session:
            for ex in exercises:
                # Check that the target KnowledgePoint exists
                check = await session.run(
                    "MATCH (kp:KnowledgePoint {name: $name}) RETURN kp.name AS name",
                    name=ex["knowledge_point"],
                )
                record = await check.single()
                if not record:
                    logger.warning("knowledge_point_not_found", name=ex["knowledge_point"], exercise_id=ex["id"])
                    skipped += 1
                    continue

                await session.run(
                    """
                    MATCH (kp:KnowledgePoint {name: $kp_name})
                    MERGE (ex:Exercise {id: $id})
                    SET ex.content = $content,
                        ex.answer = $answer,
                        ex.explanation = $explanation,
                        ex.difficulty = $difficulty,
                        ex.type = $type
                    MERGE (kp)-[:HAS_EXERCISE]->(ex)
                    """,
                    kp_name=ex["knowledge_point"],
                    id=ex["id"],
                    content=ex["content"],
                    answer=ex["answer"],
                    explanation=ex.get("explanation", ""),
                    difficulty=ex.get("difficulty", 3),
                    type=ex.get("type", "solution"),
                )
                imported += 1
                logger.info("exercise_imported", id=ex["id"], kp=ex["knowledge_point"])
    finally:
        await client.close()

    summary = {"total": len(exercises), "imported": imported, "skipped": skipped}
    logger.info("exercise_import_complete", **summary)
    return summary


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Import exercises into Neo4j")
    parser.add_argument("filepath", type=Path, help="Path to JSONL file with exercises")
    parser.add_argument("--dry-run", action="store_true", help="Validate without importing")
    args = parser.parse_args()

    if not args.filepath.exists():
        print(f"Error: File not found: {args.filepath}")
        sys.exit(1)

    asyncio.run(import_exercises(args.filepath, dry_run=args.dry_run))


if __name__ == "__main__":
    main()
