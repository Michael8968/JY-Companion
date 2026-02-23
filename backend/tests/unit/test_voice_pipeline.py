"""Tests for voice pipeline, emotion expression mapper, and enhanced fusion."""


from app.models.emotion import EmotionLabel, EmotionSource
from app.services.emotion_detector import EmotionDetector, EmotionResult
from app.services.emotion_expression_mapper import (
    ANIMATION_RULES,
    VOICE_RULES,
    EmotionExpressionMapper,
)


class TestEmotionExpressionRules:
    """Verify ≥100 emotion expression mapping rules."""

    def test_minimum_100_rules(self) -> None:
        total = len(VOICE_RULES) + len(ANIMATION_RULES)
        assert total >= 100, f"Need ≥100 rules, got {total}"

    def test_all_voice_rules_have_id(self) -> None:
        for rule in VOICE_RULES:
            assert "id" in rule
            assert rule["id"].startswith("v_")

    def test_all_animation_rules_have_id(self) -> None:
        for rule in ANIMATION_RULES:
            assert "id" in rule
            assert rule["id"].startswith("a_")

    def test_unique_rule_ids(self) -> None:
        all_ids = [r["id"] for r in VOICE_RULES] + [r["id"] for r in ANIMATION_RULES]
        assert len(all_ids) == len(set(all_ids)), "Duplicate rule IDs found"

    def test_all_rules_have_emotion(self) -> None:
        valid_emotions = {e.value for e in EmotionLabel}
        for rule in VOICE_RULES + ANIMATION_RULES:
            assert rule["emotion"] in valid_emotions, f"Invalid emotion: {rule['emotion']}"

    def test_all_rules_have_arousal_range(self) -> None:
        for rule in VOICE_RULES + ANIMATION_RULES:
            assert "arousal_min" in rule
            assert "arousal_max" in rule
            assert 0.0 <= rule["arousal_min"] <= rule["arousal_max"] <= 1.0

    def test_voice_rules_have_params(self) -> None:
        required_keys = {"speed", "pitch", "energy", "volume", "pause_density"}
        for rule in VOICE_RULES:
            assert "params" in rule
            assert required_keys.issubset(rule["params"].keys()), (
                f"Rule {rule['id']} missing keys: {required_keys - rule['params'].keys()}"
            )

    def test_animation_rules_have_params(self) -> None:
        required_keys = {"expression", "gesture", "posture", "eye_state", "mouth_style"}
        for rule in ANIMATION_RULES:
            assert "params" in rule
            assert required_keys.issubset(rule["params"].keys()), (
                f"Rule {rule['id']} missing keys: {required_keys - rule['params'].keys()}"
            )

    def test_all_emotions_have_voice_rules(self) -> None:
        covered = {r["emotion"] for r in VOICE_RULES}
        for label in EmotionLabel:
            assert label.value in covered, f"No voice rules for {label.value}"

    def test_all_emotions_have_animation_rules(self) -> None:
        covered = {r["emotion"] for r in ANIMATION_RULES}
        for label in EmotionLabel:
            assert label.value in covered, f"No animation rules for {label.value}"


class TestEmotionExpressionMapper:
    """Verify mapper returns valid params for all emotions."""

    def test_voice_params_happy(self) -> None:
        mapper = EmotionExpressionMapper()
        emotion = EmotionResult(
            label=EmotionLabel.HAPPY, valence=0.8, arousal=0.7,
            confidence=0.8, source=EmotionSource.TEXT,
        )
        params = mapper.get_voice_params(emotion)
        assert isinstance(params["speed"], float)
        assert params["speed"] >= 1.0  # Happy → faster speech

    def test_voice_params_sad(self) -> None:
        mapper = EmotionExpressionMapper()
        emotion = EmotionResult(
            label=EmotionLabel.SAD, valence=-0.6, arousal=0.3,
            confidence=0.7, source=EmotionSource.TEXT,
        )
        params = mapper.get_voice_params(emotion)
        assert params["speed"] < 1.0  # Sad → slower speech

    def test_animation_params_happy(self) -> None:
        mapper = EmotionExpressionMapper()
        emotion = EmotionResult(
            label=EmotionLabel.HAPPY, valence=0.8, arousal=0.6,
            confidence=0.8, source=EmotionSource.TEXT,
        )
        params = mapper.get_animation_params(emotion)
        positive_expressions = {"smile", "big_smile", "ecstatic", "beaming", "warm_smile", "confident_smile", "mirrored_joy"}
        assert params["expression"] in positive_expressions, f"Unexpected: {params['expression']}"

    def test_animation_params_calm(self) -> None:
        mapper = EmotionExpressionMapper()
        emotion = EmotionResult(
            label=EmotionLabel.CALM, valence=0.3, arousal=0.2,
            confidence=0.6, source=EmotionSource.TEXT,
        )
        params = mapper.get_animation_params(emotion)
        assert params["posture"] == "relaxed"

    def test_get_all_params(self) -> None:
        mapper = EmotionExpressionMapper()
        emotion = EmotionResult(
            label=EmotionLabel.ANXIOUS, valence=-0.5, arousal=0.8,
            confidence=0.7, source=EmotionSource.TEXT,
        )
        all_params = mapper.get_all_params(emotion)
        assert "voice" in all_params
        assert "animation" in all_params
        assert all_params["emotion_label"] == "anxious"

    def test_fallback_for_unknown_arousal(self) -> None:
        mapper = EmotionExpressionMapper()
        # Extreme edge: calm with very high arousal (no specific rule)
        emotion = EmotionResult(
            label=EmotionLabel.CALM, valence=0.3, arousal=0.99,
            confidence=0.5, source=EmotionSource.TEXT,
        )
        params = mapper.get_voice_params(emotion)
        assert "speed" in params


class TestEnhancedFusion:
    """Verify enhanced multi-channel fusion algorithm."""

    def test_fuse_weighted_single(self) -> None:
        detector = EmotionDetector()
        r = EmotionResult(
            label=EmotionLabel.HAPPY, valence=0.8, arousal=0.7,
            confidence=0.8, source=EmotionSource.TEXT,
        )
        fused = detector.fuse_weighted([r])
        assert fused.label == EmotionLabel.HAPPY

    def test_fuse_weighted_empty(self) -> None:
        detector = EmotionDetector()
        fused = detector.fuse_weighted([])
        assert fused.label == EmotionLabel.CALM
        assert fused.confidence == 0.0

    def test_fuse_weighted_agreement_bonus(self) -> None:
        """When text and voice agree, confidence should be boosted."""
        detector = EmotionDetector()
        text_r = EmotionResult(
            label=EmotionLabel.SAD, valence=-0.6, arousal=0.3,
            confidence=0.7, source=EmotionSource.TEXT,
        )
        voice_r = EmotionResult(
            label=EmotionLabel.SAD, valence=-0.5, arousal=0.35,
            confidence=0.6, source=EmotionSource.VOICE,
        )
        fused = detector.fuse_weighted([text_r, voice_r])
        # Agreement bonus should make confidence > average of 0.65
        assert fused.confidence > 0.65

    def test_fuse_weighted_disagreement(self) -> None:
        """When modalities disagree, use VA-space for label selection."""
        detector = EmotionDetector()
        text_r = EmotionResult(
            label=EmotionLabel.HAPPY, valence=0.8, arousal=0.7,
            confidence=0.5, source=EmotionSource.TEXT,
        )
        voice_r = EmotionResult(
            label=EmotionLabel.SAD, valence=-0.6, arousal=0.3,
            confidence=0.5, source=EmotionSource.VOICE,
        )
        fused = detector.fuse_weighted([text_r, voice_r])
        assert fused.source == EmotionSource.FUSED

    def test_fuse_weighted_custom_weights(self) -> None:
        detector = EmotionDetector()
        text_r = EmotionResult(
            label=EmotionLabel.ANXIOUS, valence=-0.5, arousal=0.8,
            confidence=0.9, source=EmotionSource.TEXT,
        )
        voice_r = EmotionResult(
            label=EmotionLabel.CALM, valence=0.3, arousal=0.2,
            confidence=0.9, source=EmotionSource.VOICE,
        )
        # Heavily weight text
        fused = detector.fuse_weighted(
            [text_r, voice_r],
            source_weights={"text": 0.9, "voice": 0.1},
        )
        # With text heavily weighted, fused valence should be negative
        assert fused.valence < 0

    def test_fuse_weighted_three_channels(self) -> None:
        detector = EmotionDetector()
        text_r = EmotionResult(
            label=EmotionLabel.ANGRY, valence=-0.6, arousal=0.9,
            confidence=0.8, source=EmotionSource.TEXT,
        )
        voice_r = EmotionResult(
            label=EmotionLabel.ANGRY, valence=-0.5, arousal=0.85,
            confidence=0.7, source=EmotionSource.VOICE,
        )
        visual_r = EmotionResult(
            label=EmotionLabel.ANGRY, valence=-0.7, arousal=0.88,
            confidence=0.6, source=EmotionSource.VISUAL,
        )
        fused = detector.fuse_weighted([text_r, voice_r, visual_r])
        # All three agree → should be angry with high confidence
        assert fused.label == EmotionLabel.ANGRY
        assert fused.confidence > 0.7


class TestVoicePipelineInit:
    """Test voice pipeline components are importable."""

    def test_import_pipeline(self) -> None:
        from app.services.voice_pipeline import VoicePipeline, VoicePipelineResult
        assert VoicePipeline is not None
        assert VoicePipelineResult is not None

    def test_pipeline_result(self) -> None:
        from app.services.voice_pipeline import VoicePipelineResult
        result = VoicePipelineResult(
            recognized_text="你好",
            response_text="你好呀",
            audio_data=b"fake",
            emotion=None,
        )
        assert result.recognized_text == "你好"
        assert result.response_text == "你好呀"
        assert result.audio_data == b"fake"


class TestSSOProvider:
    """Test SSO provider basics."""

    def test_import(self) -> None:
        from app.integrations.sso_provider import SSOProvider, SSOUserInfo
        assert SSOProvider is not None
        assert SSOUserInfo is not None

    def test_login_url_cas(self) -> None:
        from app.integrations.sso_provider import SSOProvider
        provider = SSOProvider(
            sso_base_url="https://sso.school.edu.cn",
            service_url="https://companion.school.edu.cn/callback",
            protocol="cas",
        )
        url = provider.get_login_url()
        assert "sso.school.edu.cn/login" in url
        assert "service=" in url

    def test_login_url_oauth(self) -> None:
        from app.integrations.sso_provider import SSOProvider
        provider = SSOProvider(
            sso_base_url="https://sso.school.edu.cn",
            service_url="https://companion.school.edu.cn/callback",
            protocol="oauth2",
        )
        url = provider.get_login_url()
        assert "authorize" in url
        assert "response_type=code" in url

    def test_logout_url(self) -> None:
        from app.integrations.sso_provider import SSOProvider
        provider = SSOProvider(
            sso_base_url="https://sso.school.edu.cn",
            service_url="https://companion.school.edu.cn/callback",
            protocol="cas",
        )
        url = provider.get_logout_url()
        assert "logout" in url

    def test_sso_user_info(self) -> None:
        from app.integrations.sso_provider import SSOUserInfo
        info = SSOUserInfo(
            external_id="stu001",
            username="zhangsan",
            display_name="张三",
            role="student",
            school_id="jy-hs",
            class_name="高一(3)班",
            grade="高一",
        )
        assert info.external_id == "stu001"
        assert info.role == "student"
        assert info.grade == "高一"

    def test_role_mapping_cas(self) -> None:
        from app.integrations.sso_provider import SSOProvider
        provider = SSOProvider(protocol="cas")
        assert provider._map_cas_role("student") == "student"
        assert provider._map_cas_role("Faculty") == "teacher"
        assert provider._map_cas_role("staff") == "admin"
        assert provider._map_cas_role("unknown") == "student"

    def test_role_mapping_oauth(self) -> None:
        from app.integrations.sso_provider import SSOProvider
        provider = SSOProvider(protocol="oauth2")
        assert provider._map_oauth_role("student") == "student"
        assert provider._map_oauth_role("Teacher") == "teacher"
        assert provider._map_oauth_role(["parent"]) == "parent"
        assert provider._map_oauth_role([]) == "student"
