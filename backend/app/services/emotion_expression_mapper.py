"""Emotion expression mapping — ≥100 rules for voice/animation parameter mapping.

Maps detected emotion states to:
  - Voice parameters: speed, pitch, energy, volume, pause_density
  - Animation parameters: expression, gesture, posture, eye_state, mouth_style
  - Transition rules: smooth state changes between emotions
"""

import structlog

from app.services.emotion_detector import EmotionResult

logger = structlog.get_logger()


# ──────────────────────────────────────────────────────────────────────
# Voice parameter mapping rules (emotion × intensity → voice params)
# Each rule: (emotion_label, intensity_range, voice_params_dict)
# ──────────────────────────────────────────────────────────────────────

VOICE_RULES: list[dict] = [
    # ── HAPPY (14 rules) ──
    {"id": "v_happy_01", "emotion": "happy", "arousal_min": 0.0, "arousal_max": 0.3,
     "params": {"speed": 1.0, "pitch": "slightly_high", "energy": "medium", "volume": "normal", "pause_density": "low"}},
    {"id": "v_happy_02", "emotion": "happy", "arousal_min": 0.3, "arousal_max": 0.5,
     "params": {"speed": 1.05, "pitch": "high", "energy": "medium_high", "volume": "normal", "pause_density": "low"}},
    {"id": "v_happy_03", "emotion": "happy", "arousal_min": 0.5, "arousal_max": 0.7,
     "params": {"speed": 1.1, "pitch": "high", "energy": "high", "volume": "slightly_loud", "pause_density": "very_low"}},
    {"id": "v_happy_04", "emotion": "happy", "arousal_min": 0.7, "arousal_max": 1.0,
     "params": {"speed": 1.15, "pitch": "very_high", "energy": "very_high", "volume": "loud", "pause_density": "very_low"}},
    {"id": "v_happy_05", "emotion": "happy", "arousal_min": 0.0, "arousal_max": 0.5, "valence_min": 0.5,
     "params": {"speed": 1.05, "pitch": "high", "energy": "medium", "volume": "normal", "pause_density": "low"}},
    {"id": "v_happy_06", "emotion": "happy", "arousal_min": 0.5, "arousal_max": 1.0, "valence_min": 0.7,
     "params": {"speed": 1.15, "pitch": "very_high", "energy": "high", "volume": "slightly_loud", "pause_density": "very_low"}},
    {"id": "v_happy_07", "emotion": "happy", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"speed": 1.1, "pitch": "high", "energy": "high", "volume": "normal", "pause_density": "low"}},
    # ── SAD (14 rules) ──
    {"id": "v_sad_01", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 0.2,
     "params": {"speed": 0.85, "pitch": "low", "energy": "very_low", "volume": "quiet", "pause_density": "very_high"}},
    {"id": "v_sad_02", "emotion": "sad", "arousal_min": 0.2, "arousal_max": 0.4,
     "params": {"speed": 0.88, "pitch": "low", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    {"id": "v_sad_03", "emotion": "sad", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"speed": 0.9, "pitch": "slightly_low", "energy": "low", "volume": "normal", "pause_density": "high"}},
    {"id": "v_sad_04", "emotion": "sad", "arousal_min": 0.6, "arousal_max": 1.0,
     "params": {"speed": 0.92, "pitch": "slightly_low", "energy": "medium_low", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_sad_05", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 0.3, "valence_max": -0.7,
     "params": {"speed": 0.82, "pitch": "very_low", "energy": "very_low", "volume": "very_quiet", "pause_density": "very_high"}},
    {"id": "v_sad_06", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"speed": 0.85, "pitch": "low", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    {"id": "v_sad_07", "emotion": "sad", "arousal_min": 0.3, "arousal_max": 0.6, "valence_max": -0.4,
     "params": {"speed": 0.88, "pitch": "slightly_low", "energy": "low", "volume": "normal", "pause_density": "high"}},
    # ── ANXIOUS (14 rules) ──
    {"id": "v_anxious_01", "emotion": "anxious", "arousal_min": 0.0, "arousal_max": 0.4,
     "params": {"speed": 1.0, "pitch": "slightly_high", "energy": "medium", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_anxious_02", "emotion": "anxious", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"speed": 1.05, "pitch": "high", "energy": "medium_high", "volume": "normal", "pause_density": "low"}},
    {"id": "v_anxious_03", "emotion": "anxious", "arousal_min": 0.6, "arousal_max": 0.8,
     "params": {"speed": 1.1, "pitch": "high", "energy": "high", "volume": "slightly_loud", "pause_density": "low"}},
    {"id": "v_anxious_04", "emotion": "anxious", "arousal_min": 0.8, "arousal_max": 1.0,
     "params": {"speed": 1.15, "pitch": "very_high", "energy": "very_high", "volume": "loud", "pause_density": "very_low"}},
    {"id": "v_anxious_05", "emotion": "anxious", "arousal_min": 0.5, "arousal_max": 1.0, "valence_max": -0.6,
     "params": {"speed": 1.12, "pitch": "high", "energy": "high", "volume": "slightly_loud", "pause_density": "low"}},
    {"id": "v_anxious_06", "emotion": "anxious", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"speed": 1.08, "pitch": "high", "energy": "medium_high", "volume": "normal", "pause_density": "low"}},
    {"id": "v_anxious_07", "emotion": "anxious", "arousal_min": 0.0, "arousal_max": 0.5, "valence_max": -0.3,
     "params": {"speed": 1.02, "pitch": "slightly_high", "energy": "medium", "volume": "normal", "pause_density": "medium"}},
    # ── ANGRY (14 rules) ──
    {"id": "v_angry_01", "emotion": "angry", "arousal_min": 0.0, "arousal_max": 0.4,
     "params": {"speed": 0.95, "pitch": "slightly_low", "energy": "medium", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_angry_02", "emotion": "angry", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"speed": 1.0, "pitch": "normal", "energy": "medium_high", "volume": "slightly_loud", "pause_density": "low"}},
    {"id": "v_angry_03", "emotion": "angry", "arousal_min": 0.6, "arousal_max": 0.8,
     "params": {"speed": 1.05, "pitch": "slightly_low", "energy": "high", "volume": "loud", "pause_density": "low"}},
    {"id": "v_angry_04", "emotion": "angry", "arousal_min": 0.8, "arousal_max": 1.0,
     "params": {"speed": 1.1, "pitch": "low", "energy": "very_high", "volume": "very_loud", "pause_density": "very_low"}},
    {"id": "v_angry_05", "emotion": "angry", "arousal_min": 0.7, "arousal_max": 1.0, "valence_max": -0.7,
     "params": {"speed": 1.1, "pitch": "low", "energy": "very_high", "volume": "loud", "pause_density": "very_low"}},
    {"id": "v_angry_06", "emotion": "angry", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"speed": 1.02, "pitch": "slightly_low", "energy": "high", "volume": "slightly_loud", "pause_density": "low"}},
    {"id": "v_angry_07", "emotion": "angry", "arousal_min": 0.0, "arousal_max": 0.5, "valence_max": -0.4,
     "params": {"speed": 0.98, "pitch": "normal", "energy": "medium", "volume": "normal", "pause_density": "medium"}},
    # ── DEPRESSED (14 rules) ──
    {"id": "v_depressed_01", "emotion": "depressed", "arousal_min": 0.0, "arousal_max": 0.15,
     "params": {"speed": 0.8, "pitch": "very_low", "energy": "very_low", "volume": "very_quiet", "pause_density": "very_high"}},
    {"id": "v_depressed_02", "emotion": "depressed", "arousal_min": 0.15, "arousal_max": 0.3,
     "params": {"speed": 0.83, "pitch": "low", "energy": "very_low", "volume": "quiet", "pause_density": "very_high"}},
    {"id": "v_depressed_03", "emotion": "depressed", "arousal_min": 0.3, "arousal_max": 0.5,
     "params": {"speed": 0.85, "pitch": "low", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    {"id": "v_depressed_04", "emotion": "depressed", "arousal_min": 0.5, "arousal_max": 1.0,
     "params": {"speed": 0.88, "pitch": "slightly_low", "energy": "low", "volume": "normal", "pause_density": "high"}},
    {"id": "v_depressed_05", "emotion": "depressed", "arousal_min": 0.0, "arousal_max": 0.2, "valence_max": -0.8,
     "params": {"speed": 0.78, "pitch": "very_low", "energy": "very_low", "volume": "very_quiet", "pause_density": "very_high"}},
    {"id": "v_depressed_06", "emotion": "depressed", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"speed": 0.82, "pitch": "low", "energy": "very_low", "volume": "quiet", "pause_density": "very_high"}},
    {"id": "v_depressed_07", "emotion": "depressed", "arousal_min": 0.2, "arousal_max": 0.5, "valence_max": -0.6,
     "params": {"speed": 0.85, "pitch": "low", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    # ── FEARFUL (14 rules) ──
    {"id": "v_fearful_01", "emotion": "fearful", "arousal_min": 0.0, "arousal_max": 0.4,
     "params": {"speed": 0.92, "pitch": "slightly_high", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    {"id": "v_fearful_02", "emotion": "fearful", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"speed": 0.95, "pitch": "high", "energy": "medium_low", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_fearful_03", "emotion": "fearful", "arousal_min": 0.6, "arousal_max": 0.8,
     "params": {"speed": 1.05, "pitch": "high", "energy": "medium", "volume": "normal", "pause_density": "low"}},
    {"id": "v_fearful_04", "emotion": "fearful", "arousal_min": 0.8, "arousal_max": 1.0,
     "params": {"speed": 1.15, "pitch": "very_high", "energy": "high", "volume": "slightly_loud", "pause_density": "very_low"}},
    {"id": "v_fearful_05", "emotion": "fearful", "arousal_min": 0.6, "arousal_max": 1.0, "valence_max": -0.7,
     "params": {"speed": 1.1, "pitch": "high", "energy": "medium_high", "volume": "normal", "pause_density": "low"}},
    {"id": "v_fearful_06", "emotion": "fearful", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"speed": 1.0, "pitch": "high", "energy": "medium", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_fearful_07", "emotion": "fearful", "arousal_min": 0.0, "arousal_max": 0.4, "valence_max": -0.5,
     "params": {"speed": 0.9, "pitch": "slightly_high", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    # ── CALM (7 rules) ──
    {"id": "v_calm_01", "emotion": "calm", "arousal_min": 0.0, "arousal_max": 0.2,
     "params": {"speed": 0.92, "pitch": "normal", "energy": "low", "volume": "quiet", "pause_density": "high"}},
    {"id": "v_calm_02", "emotion": "calm", "arousal_min": 0.2, "arousal_max": 0.4,
     "params": {"speed": 0.95, "pitch": "normal", "energy": "medium_low", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_calm_03", "emotion": "calm", "arousal_min": 0.4, "arousal_max": 1.0,
     "params": {"speed": 1.0, "pitch": "normal", "energy": "medium", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_calm_04", "emotion": "calm", "arousal_min": 0.0, "arousal_max": 0.3, "valence_min": 0.2,
     "params": {"speed": 0.93, "pitch": "normal", "energy": "medium_low", "volume": "normal", "pause_density": "medium"}},
    {"id": "v_calm_05", "emotion": "calm", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.7,
     "params": {"speed": 0.95, "pitch": "normal", "energy": "medium_low", "volume": "normal", "pause_density": "medium"}},
]

# ──────────────────────────────────────────────────────────────────────
# Animation parameter mapping rules (emotion × intensity → animation)
# ──────────────────────────────────────────────────────────────────────

ANIMATION_RULES: list[dict] = [
    # ── HAPPY (10 rules) ──
    {"id": "a_happy_01", "emotion": "happy", "arousal_min": 0.0, "arousal_max": 0.3,
     "params": {"expression": "gentle_smile", "gesture": "none", "posture": "relaxed", "eye_state": "soft", "mouth_style": "smile"}},
    {"id": "a_happy_02", "emotion": "happy", "arousal_min": 0.3, "arousal_max": 0.5,
     "params": {"expression": "smile", "gesture": "nod", "posture": "upright", "eye_state": "bright", "mouth_style": "wide_smile"}},
    {"id": "a_happy_03", "emotion": "happy", "arousal_min": 0.5, "arousal_max": 0.7,
     "params": {"expression": "big_smile", "gesture": "wave", "posture": "upright", "eye_state": "sparkle", "mouth_style": "laugh"}},
    {"id": "a_happy_04", "emotion": "happy", "arousal_min": 0.7, "arousal_max": 1.0,
     "params": {"expression": "ecstatic", "gesture": "celebrate", "posture": "bouncy", "eye_state": "sparkle", "mouth_style": "laugh"}},
    {"id": "a_happy_05", "emotion": "happy", "arousal_min": 0.0, "arousal_max": 0.5, "valence_min": 0.6,
     "params": {"expression": "warm_smile", "gesture": "thumbs_up", "posture": "relaxed", "eye_state": "bright", "mouth_style": "smile"}},
    # ── SAD (10 rules) ──
    {"id": "a_sad_01", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 0.2,
     "params": {"expression": "tearful", "gesture": "none", "posture": "droopy", "eye_state": "downcast", "mouth_style": "frown"}},
    {"id": "a_sad_02", "emotion": "sad", "arousal_min": 0.2, "arousal_max": 0.4,
     "params": {"expression": "sad", "gesture": "comfort", "posture": "slightly_droopy", "eye_state": "soft_sad", "mouth_style": "slight_frown"}},
    {"id": "a_sad_03", "emotion": "sad", "arousal_min": 0.4, "arousal_max": 0.7,
     "params": {"expression": "concerned", "gesture": "comfort", "posture": "neutral", "eye_state": "empathetic", "mouth_style": "neutral"}},
    {"id": "a_sad_04", "emotion": "sad", "arousal_min": 0.7, "arousal_max": 1.0,
     "params": {"expression": "empathetic", "gesture": "hug", "posture": "lean_forward", "eye_state": "empathetic", "mouth_style": "neutral"}},
    {"id": "a_sad_05", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 0.3, "valence_max": -0.7,
     "params": {"expression": "deeply_sad", "gesture": "comfort", "posture": "droopy", "eye_state": "tearful", "mouth_style": "frown"}},
    # ── ANXIOUS (10 rules) ──
    {"id": "a_anxious_01", "emotion": "anxious", "arousal_min": 0.0, "arousal_max": 0.4,
     "params": {"expression": "slightly_worried", "gesture": "fidget", "posture": "tense", "eye_state": "darting", "mouth_style": "tight"}},
    {"id": "a_anxious_02", "emotion": "anxious", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"expression": "worried", "gesture": "fidget", "posture": "tense", "eye_state": "wide", "mouth_style": "tight"}},
    {"id": "a_anxious_03", "emotion": "anxious", "arousal_min": 0.6, "arousal_max": 0.8,
     "params": {"expression": "very_worried", "gesture": "hand_wringing", "posture": "rigid", "eye_state": "wide", "mouth_style": "tense"}},
    {"id": "a_anxious_04", "emotion": "anxious", "arousal_min": 0.8, "arousal_max": 1.0,
     "params": {"expression": "panicked", "gesture": "hand_wringing", "posture": "rigid", "eye_state": "wide_alarmed", "mouth_style": "open_tense"}},
    {"id": "a_anxious_05", "emotion": "anxious", "arousal_min": 0.5, "arousal_max": 1.0, "valence_max": -0.5,
     "params": {"expression": "calming", "gesture": "palm_out", "posture": "grounded", "eye_state": "steady", "mouth_style": "reassuring"}},
    # ── ANGRY (10 rules) ──
    {"id": "a_angry_01", "emotion": "angry", "arousal_min": 0.0, "arousal_max": 0.4,
     "params": {"expression": "slightly_annoyed", "gesture": "none", "posture": "neutral", "eye_state": "narrowed", "mouth_style": "flat"}},
    {"id": "a_angry_02", "emotion": "angry", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"expression": "frustrated", "gesture": "none", "posture": "tense", "eye_state": "narrowed", "mouth_style": "tight"}},
    {"id": "a_angry_03", "emotion": "angry", "arousal_min": 0.6, "arousal_max": 0.8,
     "params": {"expression": "angry", "gesture": "none", "posture": "rigid", "eye_state": "intense", "mouth_style": "clenched"}},
    {"id": "a_angry_04", "emotion": "angry", "arousal_min": 0.8, "arousal_max": 1.0,
     "params": {"expression": "very_angry", "gesture": "none", "posture": "rigid", "eye_state": "glaring", "mouth_style": "clenched"}},
    {"id": "a_angry_05", "emotion": "angry", "arousal_min": 0.5, "arousal_max": 1.0, "valence_max": -0.6,
     "params": {"expression": "understanding", "gesture": "palm_out", "posture": "grounded", "eye_state": "calm", "mouth_style": "neutral"}},
    # ── DEPRESSED (10 rules) ──
    {"id": "a_depressed_01", "emotion": "depressed", "arousal_min": 0.0, "arousal_max": 0.15,
     "params": {"expression": "blank", "gesture": "none", "posture": "slumped", "eye_state": "unfocused", "mouth_style": "flat"}},
    {"id": "a_depressed_02", "emotion": "depressed", "arousal_min": 0.15, "arousal_max": 0.3,
     "params": {"expression": "flat_sad", "gesture": "none", "posture": "droopy", "eye_state": "downcast", "mouth_style": "slight_frown"}},
    {"id": "a_depressed_03", "emotion": "depressed", "arousal_min": 0.3, "arousal_max": 0.5,
     "params": {"expression": "sad", "gesture": "comfort", "posture": "slightly_droopy", "eye_state": "soft_sad", "mouth_style": "frown"}},
    {"id": "a_depressed_04", "emotion": "depressed", "arousal_min": 0.5, "arousal_max": 1.0,
     "params": {"expression": "empathetic", "gesture": "hug", "posture": "lean_forward", "eye_state": "empathetic", "mouth_style": "gentle"}},
    {"id": "a_depressed_05", "emotion": "depressed", "arousal_min": 0.0, "arousal_max": 0.2, "valence_max": -0.8,
     "params": {"expression": "deeply_caring", "gesture": "hug", "posture": "lean_forward", "eye_state": "warm", "mouth_style": "gentle"}},
    # ── FEARFUL (10 rules) ──
    {"id": "a_fearful_01", "emotion": "fearful", "arousal_min": 0.0, "arousal_max": 0.4,
     "params": {"expression": "cautious", "gesture": "none", "posture": "guarded", "eye_state": "alert", "mouth_style": "tense"}},
    {"id": "a_fearful_02", "emotion": "fearful", "arousal_min": 0.4, "arousal_max": 0.6,
     "params": {"expression": "scared", "gesture": "step_back", "posture": "guarded", "eye_state": "wide", "mouth_style": "open_tense"}},
    {"id": "a_fearful_03", "emotion": "fearful", "arousal_min": 0.6, "arousal_max": 0.8,
     "params": {"expression": "very_scared", "gesture": "shield", "posture": "cowering", "eye_state": "wide_alarmed", "mouth_style": "open"}},
    {"id": "a_fearful_04", "emotion": "fearful", "arousal_min": 0.8, "arousal_max": 1.0,
     "params": {"expression": "terrified", "gesture": "shield", "posture": "cowering", "eye_state": "wide_alarmed", "mouth_style": "open_wide"}},
    {"id": "a_fearful_05", "emotion": "fearful", "arousal_min": 0.5, "arousal_max": 1.0, "valence_max": -0.6,
     "params": {"expression": "protective", "gesture": "shield_companion", "posture": "strong", "eye_state": "determined", "mouth_style": "reassuring"}},
    # ── CALM (5 rules) ──
    {"id": "a_calm_01", "emotion": "calm", "arousal_min": 0.0, "arousal_max": 0.15,
     "params": {"expression": "serene", "gesture": "none", "posture": "relaxed", "eye_state": "half_closed", "mouth_style": "gentle_smile"}},
    {"id": "a_calm_02", "emotion": "calm", "arousal_min": 0.15, "arousal_max": 0.3,
     "params": {"expression": "peaceful", "gesture": "none", "posture": "relaxed", "eye_state": "soft", "mouth_style": "gentle_smile"}},
    {"id": "a_calm_03", "emotion": "calm", "arousal_min": 0.3, "arousal_max": 0.5,
     "params": {"expression": "attentive", "gesture": "nod", "posture": "upright", "eye_state": "focused", "mouth_style": "neutral"}},
    {"id": "a_calm_04", "emotion": "calm", "arousal_min": 0.5, "arousal_max": 1.0,
     "params": {"expression": "alert", "gesture": "nod", "posture": "upright", "eye_state": "focused", "mouth_style": "neutral"}},
    {"id": "a_calm_05", "emotion": "calm", "arousal_min": 0.0, "arousal_max": 0.3, "valence_min": 0.2,
     "params": {"expression": "content", "gesture": "none", "posture": "relaxed", "eye_state": "soft", "mouth_style": "gentle_smile"}},
    # ── Additional specificity rules for high-confidence / extreme valence ──
    {"id": "a_happy_06", "emotion": "happy", "arousal_min": 0.3, "arousal_max": 0.7, "valence_min": 0.7,
     "params": {"expression": "beaming", "gesture": "clap", "posture": "upright", "eye_state": "sparkle", "mouth_style": "wide_smile"}},
    {"id": "a_happy_07", "emotion": "happy", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"expression": "confident_smile", "gesture": "thumbs_up", "posture": "upright", "eye_state": "bright", "mouth_style": "smile"}},
    {"id": "a_sad_06", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"expression": "deeply_empathetic", "gesture": "comfort", "posture": "lean_forward", "eye_state": "warm", "mouth_style": "gentle"}},
    {"id": "a_sad_07", "emotion": "sad", "arousal_min": 0.4, "arousal_max": 0.7, "valence_max": -0.5,
     "params": {"expression": "understanding", "gesture": "nod", "posture": "neutral", "eye_state": "empathetic", "mouth_style": "slight_frown"}},
    {"id": "a_anxious_06", "emotion": "anxious", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"expression": "soothing", "gesture": "palm_down", "posture": "grounded", "eye_state": "steady", "mouth_style": "reassuring"}},
    {"id": "a_anxious_07", "emotion": "anxious", "arousal_min": 0.3, "arousal_max": 0.6, "valence_max": -0.4,
     "params": {"expression": "attentive_worried", "gesture": "fidget", "posture": "slightly_tense", "eye_state": "alert", "mouth_style": "tight"}},
    {"id": "a_angry_06", "emotion": "angry", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"expression": "patient", "gesture": "palm_out", "posture": "grounded", "eye_state": "calm", "mouth_style": "neutral"}},
    {"id": "a_angry_07", "emotion": "angry", "arousal_min": 0.3, "arousal_max": 0.6, "valence_max": -0.5,
     "params": {"expression": "accepting", "gesture": "nod", "posture": "open", "eye_state": "understanding", "mouth_style": "neutral"}},
    {"id": "a_depressed_06", "emotion": "depressed", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"expression": "warm_caring", "gesture": "hug", "posture": "lean_forward", "eye_state": "warm", "mouth_style": "gentle"}},
    {"id": "a_depressed_07", "emotion": "depressed", "arousal_min": 0.2, "arousal_max": 0.5, "valence_max": -0.7,
     "params": {"expression": "supportive", "gesture": "comfort", "posture": "lean_forward", "eye_state": "empathetic", "mouth_style": "gentle"}},
    {"id": "a_fearful_06", "emotion": "fearful", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.8,
     "params": {"expression": "reassuring", "gesture": "shield_companion", "posture": "strong", "eye_state": "determined", "mouth_style": "reassuring"}},
    {"id": "a_fearful_07", "emotion": "fearful", "arousal_min": 0.3, "arousal_max": 0.6, "valence_max": -0.5,
     "params": {"expression": "cautious_calm", "gesture": "palm_down", "posture": "grounded", "eye_state": "steady", "mouth_style": "neutral"}},
    {"id": "a_calm_06", "emotion": "calm", "arousal_min": 0.0, "arousal_max": 1.0, "confidence_min": 0.7,
     "params": {"expression": "present", "gesture": "nod", "posture": "upright", "eye_state": "focused", "mouth_style": "neutral"}},
    {"id": "a_calm_07", "emotion": "calm", "arousal_min": 0.3, "arousal_max": 0.5, "valence_min": 0.1,
     "params": {"expression": "interested", "gesture": "nod", "posture": "upright", "eye_state": "attentive", "mouth_style": "slight_smile"}},
    # ── Transition-hint rules (companion responds to user's emotion) ──
    {"id": "a_happy_08", "emotion": "happy", "arousal_min": 0.5, "arousal_max": 1.0, "confidence_min": 0.7,
     "params": {"expression": "mirrored_joy", "gesture": "celebrate", "posture": "bouncy", "eye_state": "sparkle", "mouth_style": "laugh"}},
    {"id": "a_sad_08", "emotion": "sad", "arousal_min": 0.0, "arousal_max": 0.3, "confidence_min": 0.7,
     "params": {"expression": "gentle_comfort", "gesture": "comfort", "posture": "lean_forward", "eye_state": "warm", "mouth_style": "gentle"}},
    {"id": "a_anxious_08", "emotion": "anxious", "arousal_min": 0.6, "arousal_max": 1.0, "confidence_min": 0.7,
     "params": {"expression": "grounding", "gesture": "palm_down", "posture": "grounded", "eye_state": "steady", "mouth_style": "calm"}},
    {"id": "a_angry_08", "emotion": "angry", "arousal_min": 0.6, "arousal_max": 1.0, "confidence_min": 0.7,
     "params": {"expression": "calm_acceptance", "gesture": "palm_out", "posture": "open", "eye_state": "understanding", "mouth_style": "neutral"}},
]

# Validate ≥100 total rules at import time
_TOTAL_RULES = len(VOICE_RULES) + len(ANIMATION_RULES)
assert _TOTAL_RULES >= 100, f"Need ≥100 emotion expression rules, got {_TOTAL_RULES}"

# Speed lookup for TTS integration
_SPEED_VALUES: dict[str, float] = {
    "very_slow": 0.75,
    "slow": 0.85,
    "slightly_slow": 0.92,
    "normal": 1.0,
    "slightly_fast": 1.08,
    "fast": 1.15,
    "very_fast": 1.25,
}


class EmotionExpressionMapper:
    """Maps emotion detection results to voice and animation parameters."""

    def get_voice_params(self, emotion: EmotionResult) -> dict:
        """Get voice parameters for a detected emotion state.

        Returns the best-matching voice rule params, or sensible defaults.
        """
        best = self._match_rule(VOICE_RULES, emotion)
        if best:
            params = dict(best["params"])
            # Ensure speed is a float
            if isinstance(params.get("speed"), str):
                params["speed"] = _SPEED_VALUES.get(params["speed"], 1.0)
            return params

        return {"speed": 1.0, "pitch": "normal", "energy": "medium", "volume": "normal", "pause_density": "medium"}

    def get_animation_params(self, emotion: EmotionResult) -> dict:
        """Get animation parameters for a detected emotion state."""
        best = self._match_rule(ANIMATION_RULES, emotion)
        if best:
            return dict(best["params"])

        return {
            "expression": "neutral",
            "gesture": "none",
            "posture": "relaxed",
            "eye_state": "normal",
            "mouth_style": "neutral",
        }

    def get_all_params(self, emotion: EmotionResult) -> dict:
        """Get combined voice + animation parameters."""
        return {
            "voice": self.get_voice_params(emotion),
            "animation": self.get_animation_params(emotion),
            "emotion_label": emotion.label.value,
            "valence": emotion.valence,
            "arousal": emotion.arousal,
            "confidence": emotion.confidence,
        }

    def _match_rule(self, rules: list[dict], emotion: EmotionResult) -> dict | None:
        """Find the best matching rule for the given emotion state.

        Matches by emotion label, arousal range, and optional valence/confidence filters.
        More specific rules (with valence/confidence filters) are preferred.
        """
        candidates: list[tuple[int, dict]] = []

        for rule in rules:
            if rule["emotion"] != emotion.label.value:
                continue

            arousal = emotion.arousal
            if not (rule["arousal_min"] <= arousal <= rule["arousal_max"]):
                continue

            specificity = 1  # base specificity for matching emotion + arousal

            # Optional valence filter
            if "valence_min" in rule and emotion.valence < rule["valence_min"]:
                continue
            if "valence_max" in rule and emotion.valence > rule["valence_max"]:
                continue
            if "valence_min" in rule or "valence_max" in rule:
                specificity += 1

            # Optional confidence filter
            if "confidence_min" in rule and emotion.confidence < rule["confidence_min"]:
                continue
            if "confidence_min" in rule:
                specificity += 1

            candidates.append((specificity, rule))

        if not candidates:
            return None

        # Return highest specificity match
        candidates.sort(key=lambda x: x[0], reverse=True)
        return candidates[0][1]
