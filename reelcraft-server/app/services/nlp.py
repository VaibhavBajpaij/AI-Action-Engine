from sumy.parsers.plaintext import PlaintextParser
from sumy.nlp.tokenizers import Tokenizer
from sumy.summarizers.text_rank import TextRankSummarizer
import nltk
from sklearn.feature_extraction.text import TfidfVectorizer
import re
import logging

logger = logging.getLogger(__name__)

def generate_nlp_outputs(title: str, text: str) -> dict:
    try:
        nltk.data.find('tokenizers/punkt_tab')
    except LookupError:
        nltk.download('punkt', quiet=True)
        nltk.download('punkt_tab', quiet=True)

    parser = PlaintextParser.from_string(text, Tokenizer("english"))
    summarizer = TextRankSummarizer()

    # Overview: 3-sentence TextRank summary
    summary_sentences = summarizer(parser.document, 3)
    overview = " ".join([str(s) for s in summary_sentences])

    # Checklist: action-oriented sentences
    # Flutter ChecklistDto expects: {position: int, text: String, optional: bool}
    top_10 = summarizer(parser.document, 10)
    checklist_texts = []
    for s in top_10:
        s_str = str(s)
        lower = s_str.lower()
        if any(w in lower for w in ['must', 'should', 'need to', 'always', 'never', 'make sure', 'ensure', 'remember', 'step']):
            checklist_texts.append(s_str)
        else:
            first_word = lower.split()[0] if lower.split() else ""
            if first_word in ['use', 'do', 'add', 'put', 'take', 'make', 'get', 'set', 'keep', 'let', 'start', 'stop']:
                checklist_texts.append(s_str)

    if not checklist_texts:
        checklist_texts = [str(s) for s in summarizer(parser.document, 5)]

    checklist = [
        {"position": i, "text": txt, "optional": False}
        for i, txt in enumerate(checklist_texts)
    ]

    # Roadmap: phase labels
    # Flutter RoadmapDto expects: {position: int, text: String}
    roadmap = []
    if checklist:
        roadmap = [
            {"position": 0, "text": "Phase 1: Getting Started"},
            {"position": 1, "text": "Phase 2: Execution"},
        ]

    # Flashcards: TF-IDF fill-in-the-blank
    # Flutter FlashcardDto expects: {front: String, back: String}
    # SRS fields (nextReviewAt, intervalDays, etc.) are managed client-side in Drift
    flashcards = []
    sentences = [str(s) for s in parser.document.sentences]
    if sentences:
        vectorizer = TfidfVectorizer(stop_words='english')
        try:
            tfidf_matrix = vectorizer.fit_transform(sentences)
            feature_names = vectorizer.get_feature_names_out()

            top_5 = summarizer(parser.document, 5)
            for s in top_5:
                try:
                    idx = sentences.index(str(s))
                    row = tfidf_matrix.getrow(idx).toarray()[0]
                    if row.max() > 0:
                        top_term_idx = row.argmax()
                        term = feature_names[top_term_idx]

                        s_str = str(s)
                        front = re.sub(rf'\b{re.escape(term)}\b', '______', s_str, flags=re.IGNORECASE)

                        if '______' in front:
                            flashcards.append({"front": front, "back": term})
                except ValueError:
                    pass
        except ValueError:
            pass

    logger.info(
        "NLP outputs generated overview_words=%d checklist=%d roadmap=%d flashcards=%d",
        len(overview.split()), len(checklist), len(roadmap), len(flashcards)
    )

    return {
        "overview": overview,
        "checklist": checklist,
        "roadmap": roadmap,
        "flashcards": flashcards,
    }
