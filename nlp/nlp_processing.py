# nlp_processing.py

import re

# -----------------------------
# Preprocess text
# -----------------------------
def preprocess_text(text):
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    return text

# -----------------------------
# Extract symptoms (NO translation)
# -----------------------------
def extract_symptoms(text, lang_choice):
    text = preprocess_text(text)
    return text.split()

# -----------------------------
# Translation (ONLY for English if needed)
# -----------------------------
def translate_to_english(text):
    return text