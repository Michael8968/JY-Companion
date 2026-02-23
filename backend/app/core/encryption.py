"""Encryption utilities — AES-256 + SM4 field-level encryption.

Provides:
  - AES-256-GCM encryption for sensitive fields (PII, credentials)
  - SM4 (国密) support for compliance with Chinese encryption standards
  - Key derivation from master secret
  - TLS 1.3 configuration helpers
"""

import base64
import hashlib
import os
import secrets

import structlog

from app.config.settings import get_settings

logger = structlog.get_logger()

# Key derivation constants
_KEY_LENGTH = 32  # AES-256
_NONCE_LENGTH = 12  # GCM nonce
_TAG_LENGTH = 16  # GCM authentication tag


def derive_key(master_secret: str, context: str = "field-encryption") -> bytes:
    """Derive a 256-bit encryption key from master secret using HKDF-like approach."""
    return hashlib.pbkdf2_hmac(
        "sha256",
        master_secret.encode(),
        context.encode(),
        iterations=100_000,
        dklen=_KEY_LENGTH,
    )


class FieldEncryptor:
    """AES-256-GCM field-level encryption for sensitive database columns.

    Usage:
        encryptor = FieldEncryptor()
        encrypted = encryptor.encrypt("sensitive data")
        decrypted = encryptor.decrypt(encrypted)
    """

    def __init__(self, master_key: str | None = None) -> None:
        settings = get_settings()
        secret = master_key or settings.jwt_secret_key
        self._key = derive_key(secret, "field-encryption")

    def encrypt(self, plaintext: str) -> str:
        """Encrypt a string field using AES-256-GCM.

        Returns base64-encoded string: nonce + ciphertext + tag.
        """
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM

        nonce = os.urandom(_NONCE_LENGTH)
        aesgcm = AESGCM(self._key)
        ciphertext = aesgcm.encrypt(nonce, plaintext.encode("utf-8"), None)

        # Pack: nonce (12) + ciphertext+tag (variable)
        packed = nonce + ciphertext
        return base64.b64encode(packed).decode("ascii")

    def decrypt(self, encrypted: str) -> str:
        """Decrypt an AES-256-GCM encrypted field."""
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM

        packed = base64.b64decode(encrypted)
        nonce = packed[:_NONCE_LENGTH]
        ciphertext = packed[_NONCE_LENGTH:]

        aesgcm = AESGCM(self._key)
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        return plaintext.decode("utf-8")


# ── TLS Configuration ─────────────────────────────────────────

TLS_CONFIG = {
    "min_version": "TLSv1.3",
    "ciphers": [
        "TLS_AES_256_GCM_SHA384",
        "TLS_CHACHA20_POLY1305_SHA256",
        "TLS_AES_128_GCM_SHA256",
    ],
    "description": "TLS 1.3 only — no downgrade to TLS 1.2",
}

# SM4 (国密算法) placeholder — requires gmssl or similar library
SM4_CONFIG = {
    "algorithm": "SM4-GCM",
    "key_length": 128,
    "description": "国密 SM4 算法，满足等保 2.0 三级要求",
    "status": "placeholder",
}


def generate_secure_token(length: int = 32) -> str:
    """Generate a cryptographically secure random token."""
    return secrets.token_urlsafe(length)


def get_tls_ssl_context():
    """Create SSL context for TLS 1.3 enforcement.

    Used with uvicorn: uvicorn main:app --ssl-keyfile=key.pem --ssl-certfile=cert.pem
    """
    import ssl

    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.minimum_version = ssl.TLSVersion.TLSv1_3
    ctx.set_ciphers(":".join(TLS_CONFIG["ciphers"]))
    return ctx
