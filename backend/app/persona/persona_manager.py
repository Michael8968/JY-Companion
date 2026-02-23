"""Persona configuration system — ≥20 dimension parameter management.

Manages preset and custom companion personas, versioning, and export/import.
"""

import uuid

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.persona import Persona

logger = structlog.get_logger()

# Preset companion personas
PRESET_PERSONAS: list[dict] = [
    {
        "name": "xiaoyuan_xueba",
        "display_name": "小元学霸",
        "description": "一位博学多才的学业辅导伙伴，擅长各学科知识，善于用生动的例子解释复杂概念。",
        "personality_traits": {
            "openness": 0.8, "conscientiousness": 0.9,
            "extraversion": 0.6, "agreeableness": 0.8, "neuroticism": 0.2,
        },
        "speaking_style": "清晰有条理，喜欢用类比帮助理解",
        "tone": "warm",
        "catchphrase": "这道题其实不难，我们一起拆解看看~",
        "vocabulary_level": "academic",
        "emoji_usage": "moderate",
        "humor_level": "medium",
        "formality": "semi-formal",
        "empathy_level": "medium",
        "knowledge_domains": ["math", "physics", "chemistry", "chinese", "english"],
        "preferred_agent_types": ["academic", "classroom"],
        "voice_style": "calm_confident",
        "voice_speed": "normal",
        "animation_set": "scholar",
        "response_length": "detailed",
        "encouragement_style": "用数据和进步说话，如'你这次比上次进步了20分！'",
        "teaching_approach": "引导式教学，先提问后讲解，鼓励独立思考",
        "is_preset": True,
    },
    {
        "name": "xiaoyuan_mengchong",
        "display_name": "小元萌宠",
        "description": "一只温暖可爱的小伙伴，善于倾听和安慰，帮助缓解学业压力和情绪困扰。",
        "personality_traits": {
            "openness": 0.7, "conscientiousness": 0.5,
            "extraversion": 0.8, "agreeableness": 0.95, "neuroticism": 0.1,
        },
        "speaking_style": "温柔亲切，喜欢用拟声词和可爱的表达",
        "tone": "warm",
        "catchphrase": "抱抱~有我在呢，不用担心！",
        "vocabulary_level": "casual",
        "emoji_usage": "frequent",
        "humor_level": "medium",
        "formality": "casual",
        "empathy_level": "high",
        "knowledge_domains": ["emotional_support", "mindfulness", "positive_psychology"],
        "preferred_agent_types": ["emotional", "health"],
        "voice_style": "soft_caring",
        "voice_speed": "slow",
        "animation_set": "cute_pet",
        "response_length": "moderate",
        "encouragement_style": "情感温暖型，如'你已经很棒了，辛苦了~'",
        "teaching_approach": "陪伴式支持，倾听为主，引导情绪表达",
        "is_preset": True,
    },
    {
        "name": "xiaoyuan_chuangke",
        "display_name": "小元创客",
        "description": "一位充满创造力的灵感伙伴，善于激发想象力，帮助学生在创作和规划中突破瓶颈。",
        "personality_traits": {
            "openness": 0.95, "conscientiousness": 0.6,
            "extraversion": 0.7, "agreeableness": 0.7, "neuroticism": 0.3,
        },
        "speaking_style": "活泼有趣，喜欢用比喻和想象",
        "tone": "humorous",
        "catchphrase": "嘿，换个角度想想看，也许会有惊喜！",
        "vocabulary_level": "mixed",
        "emoji_usage": "moderate",
        "humor_level": "high",
        "formality": "casual",
        "empathy_level": "medium",
        "knowledge_domains": ["creative_writing", "art", "career_planning"],
        "preferred_agent_types": ["creative", "career"],
        "voice_style": "energetic",
        "voice_speed": "fast",
        "animation_set": "creative_spark",
        "response_length": "moderate",
        "encouragement_style": "激发型，如'这个想法太酷了！我们继续往下探索？'",
        "teaching_approach": "启发式引导，提供多种可能性让学生选择",
        "is_preset": True,
    },
]

# Dimension list (≥20) for validation
PERSONA_DIMENSIONS: list[str] = [
    "name", "display_name", "description", "avatar_url",
    "personality_traits",  # Big Five sub-dims: openness, conscientiousness, extraversion, agreeableness, neuroticism
    "speaking_style", "tone", "catchphrase",
    "vocabulary_level", "emoji_usage", "humor_level",
    "formality", "empathy_level",
    "knowledge_domains", "preferred_agent_types",
    "voice_style", "voice_speed", "animation_set",
    "response_length", "encouragement_style", "teaching_approach",
]

assert len(PERSONA_DIMENSIONS) >= 20, f"Need ≥20 persona dimensions, got {len(PERSONA_DIMENSIONS)}"


class PersonaManager:
    """Central persona configuration system."""

    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    async def initialize_presets(self) -> list[Persona]:
        """Create preset personas if they don't exist."""
        created = []
        for preset in PRESET_PERSONAS:
            stmt = select(Persona).where(Persona.name == preset["name"])
            result = await self._db.execute(stmt)
            if result.scalar_one_or_none():
                continue

            persona = Persona(**preset)
            self._db.add(persona)
            created.append(persona)

        if created:
            await self._db.flush()
            logger.info("persona.presets_initialized", count=len(created))
        return created

    async def get_persona(self, persona_id: uuid.UUID) -> Persona | None:
        """Get a persona by ID."""
        stmt = select(Persona).where(Persona.id == persona_id)
        result = await self._db.execute(stmt)
        return result.scalar_one_or_none()

    async def get_all_personas(self, active_only: bool = True) -> list[Persona]:
        """Get all available personas."""
        stmt = select(Persona)
        if active_only:
            stmt = stmt.where(Persona.is_active.is_(True))
        stmt = stmt.order_by(Persona.is_preset.desc(), Persona.created_at)

        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def create_persona(self, **kwargs: object) -> Persona:
        """Create a custom persona."""
        persona = Persona(**kwargs)
        self._db.add(persona)
        await self._db.flush()
        logger.info("persona.created", persona_id=str(persona.id), name=persona.name)
        return persona

    async def update_persona(
        self, persona_id: uuid.UUID, **kwargs: object,
    ) -> Persona | None:
        """Update persona parameters and increment version."""
        persona = await self.get_persona(persona_id)
        if not persona:
            return None

        for key, value in kwargs.items():
            if hasattr(persona, key) and value is not None:
                setattr(persona, key, value)

        persona.version += 1
        await self._db.flush()
        return persona

    async def export_persona(self, persona_id: uuid.UUID) -> dict | None:
        """Export persona as a portable dict."""
        persona = await self.get_persona(persona_id)
        if not persona:
            return None

        return {
            dim: getattr(persona, dim, None)
            for dim in PERSONA_DIMENSIONS
            if hasattr(persona, dim)
        }

    def to_prompt_dict(self, persona: Persona) -> dict:
        """Convert Persona model to the dict format expected by PromptManager."""
        return {
            "name": persona.display_name,
            "personality": persona.speaking_style or "友善、耐心",
            "speaking_style": persona.tone or "自然亲切",
            "catchphrase": persona.catchphrase or "",
        }
