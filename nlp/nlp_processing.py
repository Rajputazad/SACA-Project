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
    return text