import base64
import os
from typing import Optional
import edge_tts
from pydantic import BaseModel
import logging

logger = logging.getLogger(__name__)


class TTSRequest(BaseModel):
    text: str
    language: str
    voice_gender: str  # "male" or "female"


class TTSResponse(BaseModel):
    audio_base64: str
    voice_name: str


# Edge TTS voice mappings for each supported language
# Using Microsoft Edge neural voices
EDGE_VOICES = {
    "en": {
        "male": "en-US-GuyNeural",
        "female": "en-US-JennyNeural",
    },
    "hi": {
        "male": "hi-IN-MadhurNeural",
        "female": "hi-IN-SwaraNeural",
    },
    "fr": {
        "male": "fr-FR-HenriNeural",
        "female": "fr-FR-DeniseNeural",
    },
    "es": {
        "male": "es-ES-AlvaroNeural",
        "female": "es-ES-ElviraNeural",
    },
    "de": {
        "male": "de-DE-ConradNeural",
        "female": "de-DE-KatjaNeural",
    },
}

# Preview text for each language
PREVIEW_TEXTS = {
    "en": "Hello, I'm Vexa. How can I help you?",
    "hi": "नमस्ते, मैं Vexa हूँ। मैं आपकी कैसे मदद कर सकती हूँ?",
    "fr": "Bonjour, je suis Vexa. Comment puis-je vous aider ?",
    "es": "Hola, soy Vexa. ¿Cómo puedo ayudarte?",
    "de": "Hallo, ich bin Vexa. Wie kann ich dir helfen?",
}


def get_voice_name(language: str, voice_gender: str) -> str:
    """Get the Edge TTS voice name for a language and gender."""
    lang_voices = EDGE_VOICES.get(language)
    if not lang_voices:
        # Default to English if language not supported
        lang_voices = EDGE_VOICES["en"]
    return lang_voices.get(voice_gender, lang_voices["female"])


def get_preview_text(language: str) -> str:
    """Get the preview text for a language."""
    return PREVIEW_TEXTS.get(language, PREVIEW_TEXTS["en"])


def get_preview_file_path(language: str, voice_gender: str) -> str:
    """Get the path to a pre-generated preview audio file."""
    base_dir = os.path.join(os.path.dirname(__file__), "previews")
    return os.path.join(base_dir, f"{language}_{voice_gender}.mp3")


def load_preview_audio(language: str, voice_gender: str) -> Optional[bytes]:
    """Load pre-generated preview audio from file."""
    file_path = get_preview_file_path(language, voice_gender)
    if os.path.exists(file_path):
        with open(file_path, "rb") as f:
            return f.read()
    return None


async def synthesize_speech(text: str, voice_name: str) -> bytes:
    """Synthesize speech using Edge TTS and return audio bytes."""
    communicate = edge_tts.Communicate(text, voice_name)
    audio_data = b""
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            audio_data += chunk["data"]
    return audio_data


async def synthesize_speech_with_fallback(text: str, voice_name: str, language: str, voice_gender: str) -> bytes:
    """
    Synthesize speech using Edge TTS with fallback to pre-generated audio.
    Tries Edge TTS first, falls back to pre-generated audio if Edge TTS fails.
    """
    # Try Edge TTS first
    try:
        audio_data = await synthesize_speech(text, voice_name)
        if audio_data:
            return audio_data
    except Exception as e:
        logger.warning(f"Edge TTS failed for {voice_name}: {e}. Falling back to pre-generated audio.")
    
    # Fallback to pre-generated audio
    audio_data = load_preview_audio(language, voice_gender)
    if audio_data:
        return audio_data
    
    # If no pre-generated audio, raise the last error
    raise Exception(f"TTS synthesis failed for {voice_name} and no fallback available")


async def generate_preview_with_fallback(language: str, voice_gender: str) -> tuple[bytes, str]:
    """
    Generate a preview sample with fallback to pre-generated audio.
    Returns (audio_bytes, voice_name).
    """
    voice_name = get_voice_name(language, voice_gender)
    preview_text = get_preview_text(language)
    
    try:
        audio_bytes = await synthesize_speech_with_fallback(
            preview_text, voice_name, language, voice_gender
        )
        return audio_bytes, voice_name
    except Exception as e:
        logger.error(f"Preview generation failed for {language}/{voice_gender}: {e}")
        raise


async def synthesize_speech_with_fallback_v2(text: str, voice_name: str, language: str, voice_gender: str) -> bytes:
    """
    Synthesize speech using Edge TTS with fallback to pre-generated audio.
    For non-preview synthesis (used in production).
    """
    try:
        return await synthesize_speech(text, voice_name)
    except Exception as e:
        logger.warning(f"Edge TTS failed for {voice_name}: {e}. Falling back to pre-generated audio.")
        audio_data = load_preview_audio(language, voice_gender)
        if audio_data:
            return audio_data
        raise