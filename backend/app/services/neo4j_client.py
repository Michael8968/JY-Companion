"""Neo4j knowledge graph client for entity-relationship queries."""

import structlog
from neo4j import AsyncGraphDatabase

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()


class KnowledgeGraphClient:
    """Neo4j client for the education knowledge graph.

    Graph schema:
    - (:Subject {name, description})
    - (:Chapter {name, subject, order})
    - (:KnowledgePoint {name, description, difficulty, importance})
    - (:Exercise {content, answer, difficulty, type})
    - (:Subject)-[:HAS_CHAPTER]->(:Chapter)
    - (:Chapter)-[:CONTAINS]->(:KnowledgePoint)
    - (:KnowledgePoint)-[:PREREQUISITE]->(:KnowledgePoint)
    - (:KnowledgePoint)-[:RELATED_TO]->(:KnowledgePoint)
    - (:KnowledgePoint)-[:HAS_EXERCISE]->(:Exercise)
    """

    def __init__(self) -> None:
        self.driver = AsyncGraphDatabase.driver(
            settings.neo4j_uri,
            auth=(settings.neo4j_user, settings.neo4j_password),
        )

    async def close(self) -> None:
        await self.driver.close()

    async def get_related_knowledge_points(self, knowledge_point_name: str, depth: int = 2) -> list[dict]:
        """Find related knowledge points within N hops."""
        query = """
        MATCH (kp:KnowledgePoint {name: $name})-[:RELATED_TO|PREREQUISITE*1..$depth]-(related:KnowledgePoint)
        RETURN DISTINCT related.name AS name,
               related.description AS description,
               related.difficulty AS difficulty
        LIMIT 10
        """
        async with self.driver.session() as session:
            result = await session.run(query, name=knowledge_point_name, depth=depth)
            return [dict(record) async for record in result]

    async def get_prerequisites(self, knowledge_point_name: str) -> list[dict]:
        """Get prerequisite knowledge points."""
        query = """
        MATCH (kp:KnowledgePoint {name: $name})-[:PREREQUISITE]->(prereq:KnowledgePoint)
        RETURN prereq.name AS name,
               prereq.description AS description,
               prereq.difficulty AS difficulty
        """
        async with self.driver.session() as session:
            result = await session.run(query, name=knowledge_point_name)
            return [dict(record) async for record in result]

    async def get_exercises_for_point(self, knowledge_point_name: str, difficulty: str | None = None) -> list[dict]:
        """Get practice exercises for a knowledge point."""
        if difficulty:
            query = """
            MATCH (kp:KnowledgePoint {name: $name})-[:HAS_EXERCISE]->(ex:Exercise)
            WHERE ex.difficulty = $difficulty
            RETURN ex.content AS content, ex.answer AS answer, ex.difficulty AS difficulty, ex.type AS type
            LIMIT 5
            """
            params = {"name": knowledge_point_name, "difficulty": difficulty}
        else:
            query = """
            MATCH (kp:KnowledgePoint {name: $name})-[:HAS_EXERCISE]->(ex:Exercise)
            RETURN ex.content AS content, ex.answer AS answer, ex.difficulty AS difficulty, ex.type AS type
            LIMIT 5
            """
            params = {"name": knowledge_point_name}

        async with self.driver.session() as session:
            result = await session.run(query, **params)
            return [dict(record) async for record in result]

    async def get_chapter_knowledge_points(self, subject: str, chapter: str) -> list[dict]:
        """Get all knowledge points in a chapter."""
        query = """
        MATCH (s:Subject {name: $subject})-[:HAS_CHAPTER]->(c:Chapter {name: $chapter})
              -[:CONTAINS]->(kp:KnowledgePoint)
        RETURN kp.name AS name,
               kp.description AS description,
               kp.difficulty AS difficulty,
               kp.importance AS importance
        ORDER BY kp.importance DESC
        """
        async with self.driver.session() as session:
            result = await session.run(query, subject=subject, chapter=chapter)
            return [dict(record) async for record in result]

    async def health_check(self) -> bool:
        try:
            async with self.driver.session() as session:
                result = await session.run("RETURN 1 AS n")
                record = await result.single()
                return record is not None and record["n"] == 1
        except Exception:
            return False
