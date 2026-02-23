"""Milvus vector database client for knowledge retrieval."""

import structlog
from pymilvus import Collection, CollectionSchema, DataType, FieldSchema, connections, utility

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()

# Collection names
KNOWLEDGE_COLLECTION = "knowledge_base"
CONVERSATION_COLLECTION = "conversation_embeddings"

# BGE-large-zh output dimension
EMBEDDING_DIM = 1024


def connect_milvus() -> None:
    """Establish connection to Milvus server."""
    connections.connect(
        alias="default",
        host=settings.milvus_host,
        port=settings.milvus_port,
    )
    logger.info("milvus.connected", host=settings.milvus_host, port=settings.milvus_port)


def ensure_knowledge_collection() -> Collection:
    """Create the knowledge base collection if it doesn't exist."""
    if utility.has_collection(KNOWLEDGE_COLLECTION):
        return Collection(KNOWLEDGE_COLLECTION)

    fields = [
        FieldSchema(name="id", dtype=DataType.VARCHAR, is_primary=True, max_length=64),
        FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=EMBEDDING_DIM),
        FieldSchema(name="content", dtype=DataType.VARCHAR, max_length=8192),
        FieldSchema(name="subject", dtype=DataType.VARCHAR, max_length=50),
        FieldSchema(name="chapter", dtype=DataType.VARCHAR, max_length=200),
        FieldSchema(name="source", dtype=DataType.VARCHAR, max_length=500),
    ]
    schema = CollectionSchema(fields=fields, description="High school knowledge base")
    collection = Collection(name=KNOWLEDGE_COLLECTION, schema=schema)

    # Create HNSW index for fast ANN search
    collection.create_index(
        field_name="embedding",
        index_params={
            "metric_type": "COSINE",
            "index_type": "HNSW",
            "params": {"M": 16, "efConstruction": 256},
        },
    )
    logger.info("milvus.collection_created", name=KNOWLEDGE_COLLECTION)
    return collection


class MilvusKnowledgeStore:
    """CRUD operations for the knowledge vector store."""

    def __init__(self) -> None:
        self.collection = ensure_knowledge_collection()

    async def insert(
        self,
        ids: list[str],
        embeddings: list[list[float]],
        contents: list[str],
        subjects: list[str],
        chapters: list[str],
        sources: list[str],
    ) -> int:
        """Insert knowledge chunks into Milvus."""
        self.collection.insert([ids, embeddings, contents, subjects, chapters, sources])
        self.collection.flush()
        return len(ids)

    async def search(
        self,
        query_embedding: list[float],
        *,
        top_k: int = 5,
        subject_filter: str | None = None,
    ) -> list[dict]:
        """Search for similar knowledge chunks.

        Returns list of dicts with keys: id, content, subject, chapter, source, score.
        """
        self.collection.load()

        search_params = {"metric_type": "COSINE", "params": {"ef": 128}}
        expr = f'subject == "{subject_filter}"' if subject_filter else None

        results = self.collection.search(
            data=[query_embedding],
            anns_field="embedding",
            param=search_params,
            limit=top_k,
            expr=expr,
            output_fields=["content", "subject", "chapter", "source"],
        )

        hits = []
        for result in results[0]:
            hits.append({
                "id": result.id,
                "score": result.score,
                "content": result.entity.get("content"),
                "subject": result.entity.get("subject"),
                "chapter": result.entity.get("chapter"),
                "source": result.entity.get("source"),
            })
        return hits
