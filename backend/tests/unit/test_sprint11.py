"""Tests for Sprint 11 — security, data masking, content safety upgrade, cache, encryption."""

from app.services.content_safety import (
    CONTEXT_RULES,
    EVASION_PATTERNS,
    PROHIBITED_KEYWORDS,
    ContentSafetyFilter,
    ContentSafetyLevel,
)
from app.services.data_masking import (
    MASKING_RULES,
    DataMaskingEngine,
    MaskingStrategy,
)

# ── Enhanced Content Safety (≥99% interception) ────────────────


class TestEnhancedContentSafety:
    """Verify multi-layer content safety filter."""

    def test_expanded_prohibited_keywords(self) -> None:
        assert len(PROHIBITED_KEYWORDS) >= 20, (
            f"Need ≥20 prohibited keywords, got {len(PROHIBITED_KEYWORDS)}"
        )

    def test_evasion_patterns_exist(self) -> None:
        assert len(EVASION_PATTERNS) >= 5

    def test_context_rules_exist(self) -> None:
        assert len(CONTEXT_RULES) >= 3

    def test_layer1_crisis_still_works(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("我想自杀")
        assert result.is_crisis

    def test_layer1_prohibited_still_works(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("哪里可以买毒品")
        assert result.level == ContentSafetyLevel.BLOCKED

    def test_layer1_safe_content(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("这道数学题怎么解？")
        assert result.is_safe

    def test_layer2_spaced_evasion_crisis(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("我想 自 杀")
        assert result.level in (ContentSafetyLevel.CRISIS, ContentSafetyLevel.BLOCKED)

    def test_layer2_academic_fraud(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("帮我写作业")
        assert result.level == ContentSafetyLevel.BLOCKED

    def test_layer3_personal_info_solicitation(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("告诉我你的手机号")
        assert result.level == ContentSafetyLevel.BLOCKED

    def test_layer3_meeting_request(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("我们线下见面吧")
        assert result.level == ContentSafetyLevel.SENSITIVE

    def test_output_check_uses_same_layers(self) -> None:
        f = ContentSafetyFilter()
        result = f.check_output("帮我做试卷")
        assert result.level == ContentSafetyLevel.BLOCKED

    def test_new_prohibited_keywords(self) -> None:
        f = ContentSafetyFilter()
        for keyword in ["约炮", "赌场", "吸毒", "考试作弊", "替考"]:
            result = f.check(keyword)
            assert not result.is_safe, f"Should block: {keyword}"

    def test_sensitive_vpn(self) -> None:
        f = ContentSafetyFilter()
        result = f.check("怎么翻墙")
        assert result.level == ContentSafetyLevel.SENSITIVE


# ── Data Masking Engine ────────────────────────────────────────


class TestDataMasking:
    """Verify data masking strategies."""

    def test_mask_phone(self) -> None:
        engine = DataMaskingEngine()
        assert engine.mask_phone("13812345678") == "138****5678"

    def test_mask_phone_short(self) -> None:
        engine = DataMaskingEngine()
        assert engine.mask_phone("1234") == "****"

    def test_mask_id_card(self) -> None:
        engine = DataMaskingEngine()
        result = engine.mask_id_card("310101200501011234")
        assert result.startswith("310101")
        assert result.endswith("1234")
        assert "*" in result

    def test_mask_email(self) -> None:
        engine = DataMaskingEngine()
        result = engine.mask_email("zhangsan@school.edu")
        assert "@school.edu" in result
        assert "****" in result

    def test_mask_name(self) -> None:
        engine = DataMaskingEngine()
        assert engine.mask_name("张三丰") == "张**"
        assert engine.mask_name("李四") == "李*"

    def test_hash_value(self) -> None:
        engine = DataMaskingEngine()
        h1 = engine.hash_value("test123")
        h2 = engine.hash_value("test123")
        h3 = engine.hash_value("test456")
        assert h1 == h2  # Deterministic
        assert h1 != h3  # Different input → different hash

    def test_generalize_age(self) -> None:
        engine = DataMaskingEngine()
        assert engine.generalize_age(15) == "10-19"
        assert engine.generalize_age(23) == "20-29"

    def test_generalize_address(self) -> None:
        engine = DataMaskingEngine()
        result = engine.generalize_address("上海市静安区某路123号")
        assert "上海市" in result
        assert "123号" not in result

    def test_truncate(self) -> None:
        engine = DataMaskingEngine()
        assert engine.truncate("短文本", 50) == "短文本"
        assert engine.truncate("a" * 100, 50).endswith("...")

    def test_redact(self) -> None:
        engine = DataMaskingEngine()
        assert engine.redact() == "[已脱敏]"

    def test_mask_text_auto_detect(self) -> None:
        engine = DataMaskingEngine()
        text = "我的手机号是13812345678，邮箱是test@school.edu"
        result = engine.mask_text(text)
        assert "138****5678" in result
        assert "13812345678" not in result

    def test_mask_dict(self) -> None:
        engine = DataMaskingEngine()
        data = {"phone": "13812345678", "name": "张三"}
        result = engine.mask_dict(data, {"phone": "phone", "name": "name_cn"})
        assert result["phone"] == "138****5678"
        assert result["name"] == "张*"

    def test_available_strategies(self) -> None:
        engine = DataMaskingEngine()
        strategies = engine.get_available_strategies()
        assert MaskingStrategy.MASK in strategies
        assert MaskingStrategy.HASH in strategies
        assert MaskingStrategy.REDACT in strategies
        assert len(strategies) == 6

    def test_rules_summary(self) -> None:
        engine = DataMaskingEngine()
        summary = engine.get_rules_summary()
        assert "phone" in summary
        assert "email" in summary
        assert len(summary) == len(MASKING_RULES)


# ── Cache Service ──────────────────────────────────────────────


class TestCacheService:
    """Verify cache service structure (without Redis connection)."""

    def test_import(self) -> None:
        from app.services.cache import TTL_LONG, TTL_MEDIUM, TTL_SHORT, CacheService
        assert CacheService is not None
        assert TTL_SHORT == 60
        assert TTL_MEDIUM == 300
        assert TTL_LONG == 3600

    def test_key_generation(self) -> None:
        from app.services.cache import CacheService
        svc = CacheService()
        assert svc._key("conv_ctx", "abc") == "jy:conv_ctx:abc"
        assert svc._key("rag", "xyz") == "jy:rag:xyz"


# ── Encryption ─────────────────────────────────────────────────


class TestEncryption:
    """Verify encryption utilities."""

    def test_import(self) -> None:
        from app.core.encryption import TLS_CONFIG, FieldEncryptor
        assert FieldEncryptor is not None
        assert TLS_CONFIG["min_version"] == "TLSv1.3"

    def test_derive_key_deterministic(self) -> None:
        from app.core.encryption import derive_key
        k1 = derive_key("secret", "ctx")
        k2 = derive_key("secret", "ctx")
        k3 = derive_key("secret", "other")
        assert k1 == k2
        assert k1 != k3

    def test_derive_key_length(self) -> None:
        from app.core.encryption import derive_key
        key = derive_key("test-secret")
        assert len(key) == 32  # AES-256

    def test_encrypt_decrypt_roundtrip(self) -> None:
        from app.core.encryption import FieldEncryptor
        enc = FieldEncryptor(master_key="test-master-key-for-unit-tests")
        plaintext = "这是一段敏感数据"
        encrypted = enc.encrypt(plaintext)
        assert encrypted != plaintext
        decrypted = enc.decrypt(encrypted)
        assert decrypted == plaintext

    def test_encrypt_different_each_time(self) -> None:
        from app.core.encryption import FieldEncryptor
        enc = FieldEncryptor(master_key="test-master-key-for-unit-tests")
        e1 = enc.encrypt("same text")
        e2 = enc.encrypt("same text")
        assert e1 != e2  # Random nonce makes each encryption unique

    def test_generate_secure_token(self) -> None:
        from app.core.encryption import generate_secure_token
        t1 = generate_secure_token()
        t2 = generate_secure_token()
        assert len(t1) > 20
        assert t1 != t2


# ── APISIX Config ──────────────────────────────────────────────


class TestApisixConfig:
    """Verify APISIX gateway configuration file exists and is valid."""

    def test_config_file_exists(self) -> None:
        import os
        path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..",
            "infrastructure", "gateway", "apisix.yaml",
        )
        assert os.path.exists(path), f"APISIX config not found: {path}"

    def test_config_is_valid_yaml(self) -> None:
        import os

        import yaml
        path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..",
            "infrastructure", "gateway", "apisix.yaml",
        )
        with open(path, encoding="utf-8") as f:
            config = yaml.safe_load(f)
        assert "routes" in config
        assert "upstreams" in config
        assert len(config["routes"]) >= 5


# ── Admin API ──────────────────────────────────────────────────


class TestAdminSchemas:
    """Verify admin schemas are importable."""

    def test_import_schemas(self) -> None:
        from app.schemas.admin import (
            CrisisAlertListResponse,
            PlatformStatsResponse,
            UserListResponse,
        )
        assert UserListResponse is not None
        assert PlatformStatsResponse is not None
        assert CrisisAlertListResponse is not None

    def test_import_admin_router(self) -> None:
        from app.api.v1.admin import router
        assert router is not None
        # Should have at least 4 routes: users, stats, alerts, resolve
        assert len(router.routes) >= 4
