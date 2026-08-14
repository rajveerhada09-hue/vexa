import asyncio
import os
import edge_tts

PREVIEW_TEXTS = {
    "en": "Hello, I'm Vexa. How can I help you?",
    "hi": "नमस्ते, मैं Vexa हूँ। मैं आपकी कैसे मदद कर सकती हूँ?",
    "fr": "Bonjour, je suis Vexa. Comment puis-je vous aider ?",
    "es": "Hola, soy Vexa. ¿Cómo puedo ayudarte?",
    "de": "Hallo, ich bin Vexa. Wie kann ich dir helfen?",
}

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

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "previews")
os.makedirs(OUTPUT_DIR, exist_ok=True)


async def generate_all():
    for language, text in PREVIEW_TEXTS.items():
        for gender in ["male", "female"]:
            voice = EDGE_VOICES[language][gender]
            output_file = os.path.join(
                OUTPUT_DIR,
                f"{language}_{gender}.mp3"
            )

            try:
                communicate = edge_tts.Communicate(text, voice)
                await communicate.save(output_file)

                size = os.path.getsize(output_file)

                if size > 0:
                    print(
                        f"Generated: {language}/{gender} "
                        f"-> {voice} ({size} bytes)"
                    )
                else:
                    print(
                        f"FAILED: {language}/{gender} "
                        f"-> generated 0-byte file"
                    )

            except Exception as e:
                print(
                    f"ERROR: {language}/{gender} "
                    f"-> {voice}: {e}"
                )


if __name__ == "__main__":
    asyncio.run(generate_all())