import asyncio
import logging
from app.services.classifier import load_classifier, classify_text
from app.services.translate import translate_to_english

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# 5 "real video" transcripts from different categories and languages
videos = [
    {
        "url": "Tech (English)",
        "lang": "en",
        "text": "So I've been using the new iPhone 15 Pro for a week now, and the titanium build actually makes a noticeable difference in hand. The A17 Pro chip crushes benchmarks, but honestly, battery life is just okay. The action button is cool though, I mapped it to the camera."
    },
    {
        "url": "Fitness (Spanish)",
        "lang": "es",
        "text": "Hoy vamos a hacer una rutina de abdomen de 5 minutos. No necesitas equipo, solo tu tapete. Vamos a empezar con planchas, mantén el core apretado, no bajes la cadera. Respira profundo. ¡Venga, sí se puede! Tres, dos, uno, descansa."
    },
    {
        "url": "Cooking (French)",
        "lang": "fr",
        "text": "Pour faire la meilleure omelette, il faut d'abord battre les œufs avec un peu de crème. Faites fondre du beurre dans la poêle, versez le mélange et laissez cuire doucement. Ajoutez du fromage râpé à la fin et pliez."
    },
    {
        "url": "Finance (English)",
        "lang": "en",
        "text": "Here is why you should never leave your money in a regular savings account. Inflation is at 3%, but your bank pays you 0.1%. You are losing purchasing power every single day. Look into high-yield savings accounts or index funds to actually build wealth."
    },
    {
        "url": "Language (Hindi)",
        "lang": "hi",
        "text": "अंग्रेजी बोलना कैसे सीखें? सबसे पहले, ग्रामर के पीछे मत भागो। रोज़ 10 मिनट अंग्रेजी सुनो और बोलने की प्रैक्टिस करो। गलतियाँ करने से डरो मत, क्योंकि बिना गलती किए कोई नहीं सीखता।"
    }
]

async def main():
    load_classifier()
    
    for v in videos:
        print(f"\n--- Testing Video: {v['url']} ({v['lang']}) ---")
        text = v['text']
        lang = v['lang']
        
        if lang and not lang.lower().startswith('en'):
            logger.info("Non-English detected (%s), translating to English", lang)
            text, failed = translate_to_english(text)
            logger.info("Translated text: %s", text)
        
        category = classify_text(text)
        print(f"Final Category: {category}\n")

if __name__ == "__main__":
    asyncio.run(main())
