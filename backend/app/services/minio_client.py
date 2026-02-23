"""MinIO object storage client for audio, documents, and media files."""


import httpx
import structlog

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()


class MinIOClient:
    """Wrapper around MinIO S3-compatible API.

    Uses httpx for async operations against MinIO's S3 REST API.
    For production, consider using aioboto3 or minio-py with async support.
    """

    def __init__(self) -> None:
        self.endpoint = settings.minio_endpoint
        self.access_key = settings.minio_access_key
        self.secret_key = settings.minio_secret_key
        self.bucket = settings.minio_bucket
        self.base_url = f"http://{self.endpoint}"

    async def upload_file(
        self,
        object_name: str,
        data: bytes,
        content_type: str = "application/octet-stream",
    ) -> str:
        """Upload a file to MinIO. Returns the object URL."""
        url = f"{self.base_url}/{self.bucket}/{object_name}"
        async with httpx.AsyncClient(timeout=120.0) as client:
            resp = await client.put(
                url,
                content=data,
                headers={
                    "Content-Type": content_type,
                },
                auth=(self.access_key, self.secret_key),
            )
            resp.raise_for_status()

        logger.info("minio.uploaded", object=object_name, size=len(data))
        return f"{self.base_url}/{self.bucket}/{object_name}"

    async def download_file(self, object_name: str) -> bytes:
        """Download a file from MinIO."""
        url = f"{self.base_url}/{self.bucket}/{object_name}"
        async with httpx.AsyncClient(timeout=120.0) as client:
            resp = await client.get(url, auth=(self.access_key, self.secret_key))
            resp.raise_for_status()
            return resp.content

    async def get_presigned_url(self, object_name: str, expires_seconds: int = 3600) -> str:
        """Generate a presigned URL for temporary access.

        Note: For a full implementation, use minio-py's presigned_get_object.
        This is a simplified placeholder returning the direct URL.
        """
        return f"{self.base_url}/{self.bucket}/{object_name}?expires={expires_seconds}"

    async def delete_file(self, object_name: str) -> None:
        """Delete a file from MinIO."""
        url = f"{self.base_url}/{self.bucket}/{object_name}"
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.delete(url, auth=(self.access_key, self.secret_key))
            resp.raise_for_status()
        logger.info("minio.deleted", object=object_name)

    async def health_check(self) -> bool:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(f"{self.base_url}/minio/health/live")
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
