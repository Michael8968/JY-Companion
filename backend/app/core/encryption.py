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

# SM4 (国密算法) configuration — 等保 2.0 三级合规
SM4_CONFIG = {
    "algorithm": "SM4-CBC",
    "key_length": 128,
    "block_size": 16,
    "description": "国密 SM4 算法，满足等保 2.0 三级要求",
}

# SM4 S-Box
_SM4_SBOX = [
    0xD6, 0x90, 0xE9, 0xFE, 0xCC, 0xE1, 0x3D, 0xB7, 0x16, 0xB6, 0x14, 0xC2, 0x28, 0xFB, 0x2C, 0x05,
    0x2B, 0x67, 0x9A, 0x76, 0x2A, 0xBE, 0x04, 0xC3, 0xAA, 0x44, 0x13, 0x26, 0x49, 0x86, 0x06, 0x99,
    0x9C, 0x42, 0x50, 0xF4, 0x91, 0xEF, 0x98, 0x7A, 0x33, 0x54, 0x0B, 0x43, 0xED, 0xCF, 0xAC, 0x62,
    0xE4, 0xB3, 0x1C, 0xA9, 0xC9, 0x08, 0xE8, 0x95, 0x80, 0xDF, 0x94, 0xFA, 0x75, 0x8F, 0x3F, 0xA6,
    0x47, 0x07, 0xA7, 0xFC, 0xF3, 0x73, 0x17, 0xBA, 0x83, 0x59, 0x3C, 0x19, 0xE6, 0x85, 0x4F, 0xA8,
    0x68, 0x6B, 0x81, 0xB2, 0x71, 0x64, 0xDA, 0x8B, 0xF8, 0xEB, 0x0F, 0x4B, 0x70, 0x56, 0x9D, 0x35,
    0x1E, 0x24, 0x0E, 0x5E, 0x63, 0x58, 0xD1, 0xA2, 0x25, 0x22, 0x7C, 0x3B, 0x01, 0x21, 0x78, 0x87,
    0xD4, 0x00, 0x46, 0x57, 0x9F, 0xD3, 0x27, 0x52, 0x4C, 0x36, 0x02, 0xE7, 0xA0, 0xC4, 0xC8, 0x9E,
    0xEA, 0xBF, 0x8A, 0xD2, 0x40, 0xC7, 0x38, 0xB5, 0xA3, 0xF7, 0xF2, 0xCE, 0xF9, 0x61, 0x15, 0xA1,
    0xE0, 0xAE, 0x5D, 0xA4, 0x9B, 0x34, 0x1A, 0x55, 0xAD, 0x93, 0x32, 0x30, 0xF5, 0x8C, 0xB1, 0xE3,
    0x1D, 0xF6, 0xE2, 0x2E, 0x82, 0x66, 0xCA, 0x60, 0xC0, 0x29, 0x23, 0xAB, 0x0D, 0x53, 0x4E, 0x6F,
    0xD5, 0xDB, 0x37, 0x45, 0xDE, 0xFD, 0x8E, 0x2F, 0x03, 0xFF, 0x6A, 0x72, 0x6D, 0x6C, 0x5B, 0x51,
    0x8D, 0x1B, 0xAF, 0x92, 0xBB, 0xDD, 0xBC, 0x7F, 0x11, 0xD9, 0x5C, 0x41, 0x1F, 0x10, 0x5A, 0xD8,
    0x0A, 0xC1, 0x31, 0x88, 0xA5, 0xCD, 0x7B, 0xBD, 0x2D, 0x74, 0xD0, 0x12, 0xB8, 0xE5, 0xB4, 0xB0,
    0x89, 0x69, 0x97, 0x4A, 0x0C, 0x96, 0x77, 0x7E, 0x65, 0xB9, 0xF1, 0x09, 0xC5, 0x6E, 0xC6, 0x84,
    0x18, 0xF0, 0x7D, 0xEC, 0x3A, 0xDC, 0x4D, 0x20, 0x79, 0xEE, 0x5F, 0x3E, 0xD7, 0xCB, 0x39, 0x48,
]

_SM4_FK = [0xA3B1BAC6, 0x56AA3350, 0x677D9197, 0xB27022DC]
_SM4_CK = [
    0x00070E15, 0x1C232A31, 0x383F464D, 0x545B6269, 0x70777E85, 0x8C939AA1, 0xA8AFB6BD, 0xC4CBD2D9,
    0xE0E7EEF5, 0xFC030A11, 0x181F262D, 0x343B4249, 0x50575E65, 0x6C737A81, 0x888F969D, 0xA4ABB2B9,
    0xC0C7CED5, 0xDCE3EAF1, 0xF8FF060D, 0x141B2229, 0x30373E45, 0x4C535A61, 0x686F767D, 0x848B9299,
    0xA0A7AEB5, 0xBCC3CAD1, 0xD8DFE6ED, 0xF4FB0209, 0x10171E25, 0x2C333A41, 0x484F565D, 0x646B7279,
]


def _sm4_rotl(x: int, n: int) -> int:
    return ((x << n) & 0xFFFFFFFF) | (x >> (32 - n))


def _sm4_tau(a: int) -> int:
    return (
        (_SM4_SBOX[(a >> 24) & 0xFF] << 24)
        | (_SM4_SBOX[(a >> 16) & 0xFF] << 16)
        | (_SM4_SBOX[(a >> 8) & 0xFF] << 8)
        | _SM4_SBOX[a & 0xFF]
    )


def _sm4_l(b: int) -> int:
    return b ^ _sm4_rotl(b, 2) ^ _sm4_rotl(b, 10) ^ _sm4_rotl(b, 18) ^ _sm4_rotl(b, 24)


def _sm4_l_prime(b: int) -> int:
    return b ^ _sm4_rotl(b, 13) ^ _sm4_rotl(b, 23)


def _sm4_key_expansion(key_bytes: bytes) -> list[int]:
    mk = [int.from_bytes(key_bytes[i * 4:(i + 1) * 4], "big") for i in range(4)]
    k = [mk[i] ^ _SM4_FK[i] for i in range(4)]
    rk = []
    for i in range(32):
        val = k[i] ^ _sm4_l_prime(_sm4_tau(k[i + 1] ^ k[i + 2] ^ k[i + 3] ^ _SM4_CK[i]))
        rk.append(val)
        k.append(val)
    return rk


def _sm4_crypt_block(block: bytes, rk: list[int]) -> bytes:
    x = [int.from_bytes(block[i * 4:(i + 1) * 4], "big") for i in range(4)]
    for i in range(32):
        x.append(x[i] ^ _sm4_l(_sm4_tau(x[i + 1] ^ x[i + 2] ^ x[i + 3] ^ rk[i])))
    return b"".join(x[35 - i].to_bytes(4, "big") for i in range(4))


class SM4Encryptor:
    """SM4-CBC field-level encryption for 等保 2.0 compliance.

    Usage:
        encryptor = SM4Encryptor()
        encrypted = encryptor.encrypt("sensitive data")
        decrypted = encryptor.decrypt(encrypted)
    """

    def __init__(self, master_key: str | None = None) -> None:
        settings = get_settings()
        secret = master_key or settings.jwt_secret_key
        key = hashlib.pbkdf2_hmac("sha256", secret.encode(), b"sm4-key", 100_000, dklen=16)
        self._enc_rk = _sm4_key_expansion(key)
        self._dec_rk = list(reversed(self._enc_rk))

    def encrypt(self, plaintext: str) -> str:
        """Encrypt using SM4-CBC with random IV. Returns base64(IV + ciphertext)."""
        iv = os.urandom(16)
        data = plaintext.encode("utf-8")
        pad_len = 16 - (len(data) % 16)
        padded = data + bytes([pad_len] * pad_len)

        prev = iv
        ct = b""
        for i in range(0, len(padded), 16):
            block = bytes(a ^ b for a, b in zip(padded[i:i + 16], prev))
            enc = _sm4_crypt_block(block, self._enc_rk)
            ct += enc
            prev = enc
        return base64.b64encode(iv + ct).decode("ascii")

    def decrypt(self, encrypted: str) -> str:
        """Decrypt SM4-CBC ciphertext."""
        raw = base64.b64decode(encrypted)
        iv, ct = raw[:16], raw[16:]

        prev = iv
        pt = b""
        for i in range(0, len(ct), 16):
            block = ct[i:i + 16]
            dec = _sm4_crypt_block(block, self._dec_rk)
            pt += bytes(a ^ b for a, b in zip(dec, prev))
            prev = block
        pad_len = pt[-1]
        return pt[:-pad_len].decode("utf-8")


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
