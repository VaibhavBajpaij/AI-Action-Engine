import logging
import re
from deep_translator import GoogleTranslator

logger = logging.getLogger(__name__)

CHUNK_LIMIT = 4500  # Google Translate free tier is 5000 chars

def chunk_text(text: str, limit: int = CHUNK_LIMIT) -> list[str]:
    """Split text into chunks under limit, trying to respect sentence boundaries."""
    if len(text) <= limit:
        return [text]

    chunks = []
    # Split by common sentence endings. Keep the delimiter with the sentence.
    sentences = re.split(r'(?<=[.!?])\s+', text)
    
    current_chunk = ""
    for sentence in sentences:
        if not sentence.strip():
            continue
            
        # If a single sentence is incredibly long (larger than limit), we have to force split it
        if len(sentence) > limit:
            if current_chunk:
                chunks.append(current_chunk.strip())
                current_chunk = ""
            
            # Force chunk the giant sentence by characters
            for i in range(0, len(sentence), limit):
                chunks.append(sentence[i:i+limit])
            continue
            
        if len(current_chunk) + len(sentence) + 1 > limit:
            chunks.append(current_chunk.strip())
            current_chunk = sentence
        else:
            if current_chunk:
                current_chunk += " " + sentence
            else:
                current_chunk = sentence

    if current_chunk:
        chunks.append(current_chunk.strip())

    return chunks

def translate_to_english(text: str) -> tuple[str, bool]:
    """
    Translates text to English if it's not English.
    Returns (translated_text, translationFailed).
    If translation fails, it falls back to the original text.
    """
    try:
        chunks = chunk_text(text)
        translated_chunks = []
        translator = GoogleTranslator(source='auto', target='en')
        
        for idx, chunk in enumerate(chunks):
            logger.info("Translating chunk %d/%d (length=%d)", idx+1, len(chunks), len(chunk))
            translated = translator.translate(chunk)
            translated_chunks.append(translated)
            
        final_text = " ".join(translated_chunks)
        return final_text, False
    except Exception as e:
        logger.error("Translation failed, falling back to original text. Error: %s", e)
        return text, True
