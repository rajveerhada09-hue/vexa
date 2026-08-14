from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import base64
import traceback
import logging

from app.tts_service import (
    TTSRequest,
    TTSResponse,
    get_voice_name,
    get_preview_text,
    synthesize_speech_with_fallback_v2 as synthesize_speech,
    generate_preview_with_fallback,
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Vexa TTS API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class PreviewRequest(BaseModel):
    language: str
    voice_gender: str


class PreviewResponse(BaseModel):
    audio_base64: str
    voice_name: str
    preview_text: str


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "vexax-tts"}


@app.post("/api/tts/synthesize", response_model=TTSResponse)
async def synthesize(request: TTSRequest):
    """Synthesize speech using Edge TTS with fallback to pre-generated audio."""
    try:
        voice_name = get_voice_name(request.language, request.voice_gender)
        audio_bytes = await synthesize_speech(
            request.text, voice_name, request.language, request.voice_gender
        )
        audio_base64 = base64.b64encode(audio_bytes).decode("utf-8")
        logger.info(f"Synthesized audio for {request.language}/{request.voice_gender} using voice {voice_name}")
        return TTSResponse(audio_base64=audio_base64, voice_name=voice_name)
    except Exception as e:
        logger.error(f"TTS synthesis failed for {request.language}/{request.voice_gender}: {e}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"TTS synthesis failed: {str(e)}")


@app.post("/api/tts/preview", response_model=PreviewResponse)
async def preview_voice(request: PreviewRequest):
    """Generate a preview sample for the voice selection screen with fallback."""
    try:
        audio_bytes, voice_name = await generate_preview_with_fallback(
            request.language, request.voice_gender
        )
        audio_base64 = base64.b64encode(audio_bytes).decode("utf-8")
        preview_text = get_preview_text(request.language)
        logger.info(f"Preview generated for {request.language}/{request.voice_gender} using voice {voice_name}")
        return PreviewResponse(
            audio_base64=audio_base64,
            voice_name=voice_name,
            preview_text=preview_text,
        )
    except Exception as e:
        logger.error(f"Preview generation failed for {request.language}/{request.voice_gender}: {e}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Preview generation failed: {str(e)}")


@app.get("/api/tts/voices")
async def list_voices():
    """List available Edge TTS voices from Microsoft."""
    from app.tts_service import EDGE_VOICES
    return {"voices": EDGE_VOICES}