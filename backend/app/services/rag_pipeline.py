"""RAG pipeline: query → embed → Milvus retrieval → Neo4j enrichment → context assembly."""

import structlog

from app.services.embedding_service import EmbeddingService

logger = structlog.get_logger()


class RAGPipeline:
    """Retrieval-Augmented Generation pipeline.

    Flow:
    1. Embed user query with BGE-large-zh
    2. Search Milvus for top-K similar knowledge chunks
    3. (Optional) Query Neo4j for related knowledge points
    4. Assemble retrieved context for LLM prompt injection

    Note: Milvus and Neo4j clients are lazily imported to avoid import-time
    connections when these services are unavailable (e.g., in unit tests).
    """

    def __init__(self) -> None:
        self.embedding_service = EmbeddingService()

    async def retrieve(
        self,
        query: str,
        *,
        top_k: int = 5,
        subject_filter: str | None = None,
        include_graph: bool = False,
    ) -> str:
        """Retrieve relevant context for a user query.

        Args:
            query: User's question text.
            top_k: Number of vector search results.
            subject_filter: Optional subject to narrow search (e.g., "数学").
            include_graph: Whether to also query Neo4j for related knowledge.

        Returns:
            Assembled context string ready for LLM prompt injection.
        """
        context_parts: list[str] = []

        # 1. Embed the query
        try:
            query_embedding = await self.embedding_service.embed_single(query)
        except Exception:
            logger.warning("rag.embedding_failed", query=query[:50])
            return ""

        # 2. Milvus vector search
        try:
            from app.services.milvus_client import MilvusKnowledgeStore

            store = MilvusKnowledgeStore()
            hits = await store.search(query_embedding, top_k=top_k, subject_filter=subject_filter)

            if hits:
                context_parts.append("--- 相关知识 ---")
                for i, hit in enumerate(hits, 1):
                    context_parts.append(
                        f"[{i}] ({hit.get('subject', '')}/{hit.get('chapter', '')}) "
                        f"{hit.get('content', '')}"
                    )
        except Exception:
            logger.warning("rag.milvus_search_failed", query=query[:50])

        # 3. Neo4j knowledge graph (optional)
        if include_graph:
            try:
                from app.services.neo4j_client import KnowledgeGraphClient

                graph = KnowledgeGraphClient()
                # Extract potential knowledge point names from query
                # (simple heuristic — future: NER extraction)
                related = await graph.get_related_knowledge_points(query[:20])
                await graph.close()

                if related:
                    context_parts.append("\n--- 关联知识点 ---")
                    for kp in related[:5]:
                        name = kp.get("name", "")
                        desc = kp.get("description", "")
                        if name:
                            context_parts.append(f"• {name}: {desc}")
            except Exception:
                logger.warning("rag.neo4j_query_failed", query=query[:50])

        return "\n".join(context_parts)


class DocumentChunker:
    """Split documents into chunks for embedding and indexing."""

    def __init__(self, chunk_size: int = 512, overlap: int = 64):
        self.chunk_size = chunk_size
        self.overlap = overlap

    def chunk(self, text: str) -> list[str]:
        """Split text into overlapping chunks."""
        if len(text) <= self.chunk_size:
            return [text]

        chunks = []
        start = 0
        while start < len(text):
            end = start + self.chunk_size
            chunk = text[start:end]
            if chunk.strip():
                chunks.append(chunk.strip())
            start = end - self.overlap
        return chunks
