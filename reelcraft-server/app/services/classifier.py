from sentence_transformers import SentenceTransformer, util
import torch
import os
import logging

logger = logging.getLogger(__name__)

model = None
category_embeddings = None

CATEGORIES = {
    "cooking": "Cooking, recipes, baking, food preparation, culinary skills. Chefs sharing meal ideas, quick dinner hacks, and kitchen techniques. Food vloggers tasting new dishes and teaching how to cook.",
    "diet": "Diet, nutrition, healthy eating, weight loss, macros, and calorie counting. Advice on keto, vegan, or intermittent fasting. Meal prep ideas and nutritional breakdowns of foods.",
    "fitness": "Fitness, workouts, exercise, gym routines, and physical training. Muscle building, weight lifting, yoga flows, or cardio sessions. Form checks and fitness motivation.",
    "sports": "Sports, athletics, games, competition, and outdoor activities. Highlights of basketball, soccer, football, or extreme sports. Athletes discussing performance and sports analysis.",
    "health": "Health, medical advice, wellness, mental health, disease prevention. Doctors and experts talking about sleep, hydration, anatomy, or managing stress and anxiety.",
    "tech": "Technology, programming, software, hardware, gadgets, and computer science. Reviews of new smartphones, AI tools, coding tutorials, and tech industry news.",
    "education": "Education, learning, study tips, academia, and science facts. Teachers explaining history, math, or physics concepts. General knowledge trivia and life hacks for students.",
    "business": "Business, entrepreneurship, startups, management, and marketing. Founders sharing startup lessons, sales tactics, and business news. Discussions on corporate strategy and leadership.",
    "finance": "Finance, investing, stock market, personal finance, and money management. Tips on saving money, passive income, real estate, crypto, and financial literacy.",
    "travel": "Travel, tourism, vacations, destinations, and exploring the world. Vloggers showcasing hotels, hidden gems, local cultures, and travel itineraries.",
    "lifestyle": "Lifestyle, daily routine, fashion, beauty, and personal development. Day-in-the-life vlogs, outfit ideas, makeup tutorials, and aesthetic room tours.",
    "career": "Career advice, job hunting, interviews, resumes, and professional growth. Tips on negotiating salary, navigating office politics, and finding remote work.",
    "diy": "DIY, crafts, home improvement, building things, and handmade projects. Woodworking, room makeovers, sewing tutorials, and fixing things around the house.",
    "language": "Language learning, vocabulary, grammar, linguistics, and speaking practice. Teachers explaining slang, pronunciation, and how to become fluent in a foreign language.",
    "other": "Miscellaneous content that does not fit into specific categories. General entertainment, random memes, or highly specific niche topics."
}
category_names = list(CATEGORIES.keys())

def load_classifier():
    global model, category_embeddings
    offline = os.environ.get("HF_HUB_OFFLINE", "0") == "1"
    kwargs = {"local_files_only": True} if offline else {}
    logger.info("Loading sentence-transformers model offline=%s", offline)
    model = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2", **kwargs)
    descriptions = list(CATEGORIES.values())
    category_embeddings = model.encode(descriptions, convert_to_tensor=True)
    logger.info("sentence-transformers classifier loaded %d categories", len(CATEGORIES))

def classify_text(text: str) -> str:
    if not text.strip():
        return "uncategorized"
        
    text_embedding = model.encode(text, convert_to_tensor=True)
    cosine_scores = util.cos_sim(text_embedding, category_embeddings)[0]
    
    # Get top 3 scores
    top_scores, top_indices = torch.topk(cosine_scores, k=3)
    
    top_3_log = []
    for score, idx in zip(top_scores, top_indices):
        cat_name = category_names[idx.item()]
        top_3_log.append(f"{cat_name}: {score.item():.3f}")
        
    logger.info("Classification top 3: %s", ", ".join(top_3_log))
    
    top_score_idx = top_indices[0].item()
    top_score = top_scores[0].item()
    
    if top_score < 0.22:
        return "uncategorized"
    return category_names[top_score_idx]
