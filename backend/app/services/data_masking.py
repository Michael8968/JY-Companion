"""Data masking / desensitization engine — multi-strategy rule system.

Strategies:
  - MASK: Replace characters with * (e.g., phone: 138****1234)
  - GENERALIZE: Reduce precision (e.g., age: 15→10-19)
  - HASH: One-way hash (e.g., ID number → SHA-256 digest)
  - TRUNCATE: Keep only prefix (e.g., name: 张**)
  - REDACT: Fully remove (e.g., [已脱敏])
  - ENCRYPT: Reversible AES-256 encryption (for authorized recovery)

Rules are applied based on field type detected via regex or explicit config.
"""

import hashlib
import re

import structlog

logger = structlog.get_logger()


class MaskingStrategy:
    """Enum-like constants for masking strategies."""
    MASK = "mask"
    GENERALIZE = "generalize"
    HASH = "hash"
    TRUNCATE = "truncate"
    REDACT = "redact"
    ENCRYPT = "encrypt"


# ── Field type detection patterns ──────────────────────────────

FIELD_PATTERNS: list[dict] = [
    {"field_type": "phone", "pattern": re.compile(r"1[3-9]\d{9}"), "strategy": MaskingStrategy.MASK},
    {"field_type": "id_card", "pattern": re.compile(r"\d{17}[\dXx]"), "strategy": MaskingStrategy.MASK},
    {"field_type": "email", "pattern": re.compile(r"[\w.+-]+@[\w-]+\.[\w.]+"), "strategy": MaskingStrategy.MASK},
    {"field_type": "name_cn", "pattern": re.compile(r"[\u4e00-\u9fa5]{2,4}"), "strategy": MaskingStrategy.TRUNCATE},
    {"field_type": "bank_card", "pattern": re.compile(r"\d{16,19}"), "strategy": MaskingStrategy.MASK},
    {"field_type": "address", "pattern": re.compile(r"[\u4e00-\u9fa5]{2,}(省|市|区|县|路|街|号)"), "strategy": MaskingStrategy.GENERALIZE},
]

# ── Masking rules per field type ───────────────────────────────

MASKING_RULES: dict[str, dict] = {
    "phone": {
        "strategy": MaskingStrategy.MASK,
        "description": "手机号码脱敏",
        "keep_prefix": 3,
        "keep_suffix": 4,
        "mask_char": "*",
    },
    "id_card": {
        "strategy": MaskingStrategy.MASK,
        "description": "身份证号脱敏",
        "keep_prefix": 6,
        "keep_suffix": 4,
        "mask_char": "*",
    },
    "email": {
        "strategy": MaskingStrategy.MASK,
        "description": "邮箱脱敏",
        "keep_prefix": 2,
        "keep_suffix": 0,
        "mask_at_domain": True,
        "mask_char": "*",
    },
    "name_cn": {
        "strategy": MaskingStrategy.TRUNCATE,
        "description": "中文姓名脱敏",
        "keep_chars": 1,
        "mask_char": "*",
    },
    "bank_card": {
        "strategy": MaskingStrategy.MASK,
        "description": "银行卡号脱敏",
        "keep_prefix": 4,
        "keep_suffix": 4,
        "mask_char": "*",
    },
    "address": {
        "strategy": MaskingStrategy.GENERALIZE,
        "description": "地址泛化",
        "level": "city",
    },
    "student_id": {
        "strategy": MaskingStrategy.HASH,
        "description": "学号哈希",
    },
    "password": {
        "strategy": MaskingStrategy.REDACT,
        "description": "密码完全脱敏",
    },
    "conversation_content": {
        "strategy": MaskingStrategy.TRUNCATE,
        "description": "对话内容截断",
        "max_length": 50,
        "mask_char": "...",
    },
}


class DataMaskingEngine:
    """Rule-based data masking engine with multiple strategies."""

    def mask_phone(self, phone: str) -> str:
        """Mask phone number: 13812345678 → 138****5678."""
        if len(phone) < 7:
            return "*" * len(phone)
        return phone[:3] + "****" + phone[-4:]

    def mask_id_card(self, id_card: str) -> str:
        """Mask ID card: 310101200501011234 → 310101********1234."""
        if len(id_card) < 10:
            return "*" * len(id_card)
        return id_card[:6] + "*" * (len(id_card) - 10) + id_card[-4:]

    def mask_email(self, email: str) -> str:
        """Mask email: zhangsan@school.edu → zh****@school.edu."""
        if "@" not in email:
            return "****"
        local, domain = email.rsplit("@", 1)
        masked_local = local[0] + "****" if len(local) <= 2 else local[:2] + "****"
        return f"{masked_local}@{domain}"

    def mask_name(self, name: str) -> str:
        """Mask Chinese name: 张三丰 → 张**."""
        if not name:
            return ""
        return name[0] + "*" * (len(name) - 1)

    def hash_value(self, value: str, salt: str = "jy-companion") -> str:
        """One-way SHA-256 hash with salt."""
        return hashlib.sha256(f"{salt}:{value}".encode()).hexdigest()[:16]

    def generalize_age(self, age: int) -> str:
        """Generalize age to range: 15 → 10-19."""
        decade = (age // 10) * 10
        return f"{decade}-{decade + 9}"

    def generalize_address(self, address: str) -> str:
        """Generalize address to city level."""
        # Keep up to city, remove district/street/number
        match = re.match(r"([\u4e00-\u9fa5]+(?:省|自治区))?([\u4e00-\u9fa5]+(?:市))?", address)
        if match:
            parts = [p for p in match.groups() if p]
            return "".join(parts) if parts else "[已脱敏]"
        return "[已脱敏]"

    def truncate(self, text: str, max_length: int = 50) -> str:
        """Truncate text with ellipsis."""
        if len(text) <= max_length:
            return text
        return text[:max_length] + "..."

    def redact(self) -> str:
        """Fully redact — replace with placeholder."""
        return "[已脱敏]"

    def mask_text(self, text: str) -> str:
        """Auto-detect and mask sensitive data in free text.

        Scans for phone numbers, ID cards, emails in the text and masks them in place.
        """
        result = text

        # Phone numbers
        result = re.sub(
            r"1[3-9]\d{9}",
            lambda m: self.mask_phone(m.group()),
            result,
        )

        # ID cards (18 digits)
        result = re.sub(
            r"\d{17}[\dXx]",
            lambda m: self.mask_id_card(m.group()),
            result,
        )

        # Emails
        result = re.sub(
            r"[\w.+-]+@[\w-]+\.[\w.]+",
            lambda m: self.mask_email(m.group()),
            result,
        )

        return result

    def mask_dict(self, data: dict, field_rules: dict[str, str] | None = None) -> dict:
        """Mask sensitive fields in a dictionary.

        Args:
            data: Input dictionary.
            field_rules: Mapping of field_name → field_type (from MASKING_RULES).
                         If None, uses auto-detection.
        """
        rules = field_rules or {}
        result = {}

        for key, value in data.items():
            if not isinstance(value, str):
                result[key] = value
                continue

            field_type = rules.get(key)
            if field_type == "phone":
                result[key] = self.mask_phone(value)
            elif field_type == "id_card":
                result[key] = self.mask_id_card(value)
            elif field_type == "email":
                result[key] = self.mask_email(value)
            elif field_type == "name_cn":
                result[key] = self.mask_name(value)
            elif field_type == "password":
                result[key] = self.redact()
            elif field_type == "hash":
                result[key] = self.hash_value(value)
            else:
                # Auto-detect in free text fields
                result[key] = self.mask_text(value)

        return result

    def get_available_strategies(self) -> list[str]:
        """List all available masking strategies."""
        return [
            MaskingStrategy.MASK,
            MaskingStrategy.GENERALIZE,
            MaskingStrategy.HASH,
            MaskingStrategy.TRUNCATE,
            MaskingStrategy.REDACT,
            MaskingStrategy.ENCRYPT,
        ]

    def get_rules_summary(self) -> dict[str, str]:
        """Get a summary of all configured masking rules."""
        return {k: v["description"] for k, v in MASKING_RULES.items()}
