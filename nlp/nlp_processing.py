<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> origin/master-ML
# nlp_processing.py

import re

# -----------------------------
# Stopwords (English only)
# -----------------------------
stopwords = {
    "a", "an", "the", "is", "are", "was", "were", "am",
    "i", "you", "he", "she", "it", "we", "they",
    "and", "or", "but", "if", "then",
    "have", "has", "had",
    "do", "does", "did",
    "of", "in", "on", "at", "to", "for"
}

# -----------------------------
# Known symptoms list (can expand later)
# -----------------------------
known_symptoms = {
    "fever", "cough", "headache", "pain", "cold", "fatigue",
    "gämaŋ", "garrtjarr", "nhäl"  # Yolngu examples
}

# -----------------------------
# Preprocess text
# -----------------------------
def preprocess_text(text):
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    return text

# -----------------------------
# Improved Symptom Extraction
# -----------------------------
def extract_symptoms(text, lang_choice):
    text = preprocess_text(text)
    words = text.split()

    symptoms = []

    for word in words:
        # Remove English stopwords
        if word in stopwords:
            continue

        # Keep only meaningful symptom words
        if word in known_symptoms:
            symptoms.append(word)

    return symptoms

# -----------------------------
# Translation (keep simple)
# -----------------------------
def translate_to_english(text):
<<<<<<< HEAD
=======
=======
<<<<<<< HEAD
import re
import os
import joblib
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
APP_INTEGRATION_DIR = os.path.join(PROJECT_DIR, "app_integration")
PREPROC_PATH = os.path.join(APP_INTEGRATION_DIR, "preprocessing_objects.pkl")

_UNIQUE_SYMPTOMS = None

# Yolngu / dictionary words mapped to ML symptom names
YOLNGU_TO_SYMPTOM = {
    "bambay": "blurred vision",
    "bäka": "leg pain",
    "balkatj": "back pain",
    "bälim'bun": "fever",
    "bälimbun": "fever",
    "gurru": "headache",
    "ŋoy": "nausea",
    "marrtji": "dizziness"
}


def _load_symptom_vocab():
    global _UNIQUE_SYMPTOMS

    if _UNIQUE_SYMPTOMS is None:
        if not os.path.exists(PREPROC_PATH):
            raise FileNotFoundError(f"Preprocessing file not found: {PREPROC_PATH}")

        preproc = joblib.load(PREPROC_PATH)
        _UNIQUE_SYMPTOMS = preproc["unique_symptoms"]
        logger.info(f"Loaded {len(_UNIQUE_SYMPTOMS)} canonical symptoms.")

    return _UNIQUE_SYMPTOMS


def preprocess_text(text):
    text = text.lower()
    text = re.sub(r"[^\w\s'äŋḏḻṉṱ]", "", text)
    return text.strip()


def extract_symptoms(text, lang_choice=1):
    if not text:
        return []

    cleaned = preprocess_text(text)
    vocab = _load_symptom_vocab()
    matched = []

    # 1. Direct English symptom matching
    for symptom in vocab:
        if symptom in cleaned:
            matched.append(symptom)

    # 2. Yolngu mapped symptom matching
    words = cleaned.split()
    for word in words:
        if word in YOLNGU_TO_SYMPTOM:
            mapped_symptom = YOLNGU_TO_SYMPTOM[word]

            # only add if the ML model knows this symptom
            if mapped_symptom in vocab and mapped_symptom not in matched:
                matched.append(mapped_symptom)

    if lang_choice == 2 and not matched:
        logger.warning("Yolngu input detected, but no mapped medical symptom found.")

    return matched


def translate_to_english(text):
=======
# nlp_processing.py

import re

# -----------------------------
# Stopwords (English only)
# -----------------------------
stopwords = {
    "a", "an", "the", "is", "are", "was", "were", "am",
    "i", "you", "he", "she", "it", "we", "they",
    "and", "or", "but", "if", "then",
    "have", "has", "had",
    "do", "does", "did",
    "of", "in", "on", "at", "to", "for"
}

# -----------------------------
# Known symptoms list (can expand later)
# -----------------------------
known_symptoms = {
    "fever", "cough", "headache", "pain", "cold", "fatigue",
    "gämaŋ", "garrtjarr", "nhäl"  # Yolngu examples
}

# -----------------------------
# Preprocess text
# -----------------------------
def preprocess_text(text):
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    return text

# -----------------------------
# Improved Symptom Extraction
# -----------------------------
def extract_symptoms(text, lang_choice):
    text = preprocess_text(text)
    words = text.split()

    symptoms = []

    for word in words:
        # Remove English stopwords
        if word in stopwords:
            continue

        # Keep only meaningful symptom words
        if word in known_symptoms:
            symptoms.append(word)

    return symptoms

# -----------------------------
# Translation (keep simple)
# -----------------------------
def translate_to_english(text):
>>>>>>> 72ee80343629e2f46c34c344a919a1604912dbd0
>>>>>>> 2edbceb (Added ML + NLP integration)
>>>>>>> origin/master-ML
    return text