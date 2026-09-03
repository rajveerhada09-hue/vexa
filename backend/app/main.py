from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
import httpx
import os
import json
import base64
import traceback
import logging

load_dotenv()

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

@app.post("/api/exotel/test-call")
async def exotel_test_call():
    api_key = os.getenv("EXOTEL_API_KEY")
    api_token = os.getenv("EXOTEL_API_TOKEN")
    account_sid = os.getenv("EXOTEL_ACCOUNT_SID")
    exophone = os.getenv("EXOTEL_PHONE_NUMBER")
    test_number = os.getenv("EXOTEL_TEST_NUMBER")

    if not all([api_key, api_token, account_sid, exophone, test_number]):
        raise HTTPException(
            status_code=500,
            detail="Missing Exotel environment variables.",
        )

    stream_url = os.getenv(
        "EXOTEL_STREAM_URL",
        "wss://inviting-lupous-jax.ngrok-free.dev/ws/exotel",
    )

    url = (
    f"https://api.exotel.com/"
    f"v1/Accounts/{account_sid}/Calls/connect"
)

    data = {
        "from": test_number,
        "callerid": exophone,
        "streamurl": stream_url,
        "streamtype": "bidirectional",
    }

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                url,
                auth=(api_key, api_token),
                data=data,
            )

        logger.info(
            "Exotel response: %s %s",
            response.status_code,
            response.text,
        )

        if response.status_code >= 400:
            raise HTTPException(
                status_code=response.status_code,
                detail=response.text,
            )

        return {
            "success": True,
            "exotel_response": response.text,
            "stream_url": stream_url,
        }

    except httpx.RequestError as e:
        logger.exception("Could not reach Exotel")
        raise HTTPException(
            status_code=502,
            detail=f"Could not reach Exotel: {e}",
        )

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

@app.websocket("/ws/exotel")
async def exotel_websocket(websocket: WebSocket):
    await websocket.accept()

    stream_sid = None

    try:
        while True:
            message = await websocket.receive_text()
            event = json.loads(message)

            event_type = event.get("event")

            if event_type == "connected":
                logger.info("Exotel WebSocket connected")

            elif event_type == "start":
                stream_sid = event["start"]["stream_sid"]

                logger.info(
                    f"Call started | "
                    f"stream_sid={stream_sid} | "
                    f"from={event['start'].get('from')} | "
                    f"to={event['start'].get('to')}"
                )

            elif event_type == "media":
                if not stream_sid:
                    continue

                # TEMPORARY TEST:
                # Send exactly the caller's audio back.
                await websocket.send_text(
                    json.dumps({
                        "event": "media",
                        "stream_sid": stream_sid,
                        "media": {
                            "payload": event["media"]["payload"]
                        }
                    })
                )

            elif event_type == "stop":
                logger.info("Exotel call stopped")
                break

    except WebSocketDisconnect:
        logger.info("Exotel WebSocket disconnected")

    except Exception:
        logger.exception("Error in Exotel WebSocket")