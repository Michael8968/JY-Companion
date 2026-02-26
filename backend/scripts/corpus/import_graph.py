"""Import knowledge graph data into Neo4j.

Reads JSONL files containing subjects, chapters, knowledge points, and their
relationships, then creates the corresponding nodes and edges in Neo4j.

Usage:
    python -m scripts.corpus.import_graph data/corpus/math/knowledge_graph.jsonl
    python -m scripts.corpus.import_graph data/corpus/math/knowledge_graph.jsonl --dry-run
"""

import asyncio
import json
import sys
from pathlib import Path

import structlog

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

logger = structlog.get_logger()


def load_graph_data(filepath: Path) -> dict[str, list[dict]]:
    """Load graph data from JSONL, grouped by type."""
    data: dict[str, list[dict]] = {
        "subject": [],
        "chapter": [],
        "knowledge_point": [],
    }
    with open(filepath, encoding="utf-8") as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
                item_type = item.get("type")
                if item_type not in data:
                    logger.warning("unknown_type", lineno=lineno, type=item_type)
                    continue
                data[item_type].append(item)
            except json.JSONDecodeError as e:
                logger.warning("skip_invalid_line", lineno=lineno, error=str(e))
    return data


async def import_graph(filepath: Path, *, dry_run: bool = False) -> dict:
    """Import knowledge graph from JSONL into Neo4j.

    Processing order:
    1. Create Subject nodes
    2. Create Chapter nodes + HAS_CHAPTER edges
    3. Create KnowledgePoint nodes + CONTAINS edges
    4. Create PREREQUISITE and RELATED_TO edges
    """
    data = load_graph_data(filepath)
    total = sum(len(v) for v in data.values())
    logger.info(
        "graph_data_loaded",
        subjects=len(data["subject"]),
        chapters=len(data["chapter"]),
        knowledge_points=len(data["knowledge_point"]),
    )

    if dry_run:
        for category, items in data.items():
            for item in items:
                logger.info("graph_preview", type=category, name=item.get("name", "?"))
        return {"total": total, "imported": 0, "dry_run": True}

    from app.services.neo4j_client import KnowledgeGraphClient

    client = KnowledgeGraphClient()
    created = 0

    try:
        async with client.driver.session() as session:
            # 1. Create Subjects
            for s in data["subject"]:
                await session.run(
                    "MERGE (s:Subject {name: $name}) SET s.description = $desc",
                    name=s["name"],
                    desc=s.get("description", ""),
                )
                created += 1
                logger.info("created_subject", name=s["name"])

            # 2. Create Chapters with HAS_CHAPTER edges
            for ch in data["chapter"]:
                await session.run(
                    """
                    MATCH (s:Subject {name: $subject})
                    MERGE (c:Chapter {name: $name, subject: $subject})
                    SET c.order = $order
                    MERGE (s)-[:HAS_CHAPTER]->(c)
                    """,
                    name=ch["name"],
                    subject=ch["subject"],
                    order=ch.get("order", 0),
                )
                created += 1
                logger.info("created_chapter", name=ch["name"], subject=ch["subject"])

            # 3. Create KnowledgePoints with CONTAINS edges
            for kp in data["knowledge_point"]:
                await session.run(
                    """
                    MATCH (c:Chapter {name: $chapter, subject: $subject})
                    MERGE (kp:KnowledgePoint {name: $name})
                    SET kp.description = $description,
                        kp.difficulty = $difficulty,
                        kp.importance = $importance
                    MERGE (c)-[:CONTAINS]->(kp)
                    """,
                    name=kp["name"],
                    chapter=kp["chapter"],
                    subject=kp["subject"],
                    description=kp.get("description", ""),
                    difficulty=kp.get("difficulty", 1),
                    importance=kp.get("importance", 3),
                )
                created += 1
                logger.info("created_knowledge_point", name=kp["name"])

            # 4. Create PREREQUISITE and RELATED_TO edges
            for kp in data["knowledge_point"]:
                for prereq_name in kp.get("prerequisites", []):
                    await session.run(
                        """
                        MATCH (kp:KnowledgePoint {name: $name})
                        MATCH (prereq:KnowledgePoint {name: $prereq})
                        MERGE (kp)-[:PREREQUISITE]->(prereq)
                        """,
                        name=kp["name"],
                        prereq=prereq_name,
                    )
                    logger.debug("created_prerequisite", from_=kp["name"], to=prereq_name)

                for related_name in kp.get("related", []):
                    await session.run(
                        """
                        MATCH (kp:KnowledgePoint {name: $name})
                        MATCH (rel:KnowledgePoint {name: $related})
                        MERGE (kp)-[:RELATED_TO]->(rel)
                        """,
                        name=kp["name"],
                        related=related_name,
                    )
                    logger.debug("created_related", from_=kp["name"], to=related_name)
    finally:
        await client.close()

    summary = {"total": total, "created": created}
    logger.info("graph_import_complete", **summary)
    return summary


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Import knowledge graph into Neo4j")
    parser.add_argument("filepath", type=Path, help="Path to JSONL file with graph data")
    parser.add_argument("--dry-run", action="store_true", help="Validate without importing")
    args = parser.parse_args()

    if not args.filepath.exists():
        print(f"Error: File not found: {args.filepath}")
        sys.exit(1)

    asyncio.run(import_graph(args.filepath, dry_run=args.dry_run))


if __name__ == "__main__":
    main()
