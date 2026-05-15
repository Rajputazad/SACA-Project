import json
import os
import re

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
YOLNGU_DICTIONARY_PATH = os.path.join(BASE_DIR, "resources", "yolngu_dictionary.json")
_DICTIONARY_SYMPTOM_MAP = None

STOPWORDS = {
    "a", "an", "the", "is", "are", "was", "were", "am", "i", "im", "i'm",
    "you", "he", "she", "it", "we", "they", "and", "or", "but", "if",
    "then", "have", "has", "had", "do", "does", "did", "of", "in", "on",
    "at", "to", "for", "with", "my", "me", "feel", "feeling", "got",
    "been", "having", "also", "very", "really", "bad", "severe", "mild",
}

DEFAULT_SYMPTOMS = [
    "abdominal pain", "anxiety", "appetite loss", "arm pain", "back pain",
    "bleeding", "bleeding heavy", "bloating", "blurred vision", "burn",
    "chest pain", "confusion", "constipation", "cough", "depression",
    "diarrhea", "dizziness", "ear pain", "eye pain", "fainting", "fatigue",
    "fever", "foot pain", "headache", "insomnia", "itching", "joint pain",
    "knee pain", "leg pain", "muscle pain", "nausea", "neck pain",
    "numbness", "rash", "runny nose", "shortness of breath", "shoulder pain",
    "skin infection", "skin redness", "sneezing", "sore throat", "sweating",
    "swelling", "tremors", "vomiting", "weakness", "weight gain",
    "weight loss", "wheezing", "wound",
]

ENGLISH_SYNONYMS = {
    "arm pain": "arm pain",
    "back stiffness": "back pain",
    "belly pain": "abdominal pain",
    "bleeding with pain": "bleeding heavy",
    "bloating": "abdominal pain",
    "body bleeding": "bleeding",
    "body pain": "muscle pain",
    "breathing difficulty": "shortness of breath",
    "burning chest pain": "chest pain",
    "burning pain": "abdominal pain",
    "burning skin": "burn",
    "can't breathe": "shortness of breath",
    "cant breathe": "shortness of breath",
    "cluster headache": "headache",
    "confusion": "confusion",
    "constipation": "abdominal pain",
    "cough with chest pain": "chest pain",
    "cough with fever": "fever",
    "cramping pain": "abdominal pain",
    "difficulty breathing": "shortness of breath",
    "dizziness when standing": "dizziness",
    "dizziness with blurred vision": "blurred vision",
    "dry cough": "cough",
    "ear pain": "ear pain",
    "eye pain": "eye pain",
    "fainting": "fainting",
    "fever with chills": "fever",
    "fever with sweating": "fever",
    "foot pain": "foot pain",
    "headache with eye pain": "headache",
    "heartburn": "chest pain",
    "heavy bleeding": "bleeding heavy",
    "high fever": "fever",
    "itching": "itching",
    "knee pain": "knee pain",
    "leg pain": "leg pain",
    "light dizziness": "dizziness",
    "low fever": "fever",
    "lower back pain": "back pain",
    "migraine headache": "headache",
    "migraine with light sensitivity": "headache",
    "migraine with nausea": "headache",
    "migraine with vision changes": "blurred vision",
    "migraine": "headache",
    "mild sore throat": "sore throat",
    "neck pain": "neck pain",
    "numbness": "numbness",
    "pain after eating": "abdominal pain",
    "pain when swallowing": "sore throat",
    "pain while moving": "muscle pain",
    "pain with breathing": "shortness of breath",
    "pressure / tightness": "chest pain",
    "pressure tightness": "chest pain",
    "repeated vomiting": "vomiting",
    "sharp chest pain": "chest pain",
    "sharp stomach pain": "abdominal pain",
    "shoulder pain": "shoulder pain",
    "sinus headache": "headache",
    "skin infection": "skin infection",
    "skin redness": "skin redness",
    "small bleeding": "bleeding",
    "sore back": "back pain",
    "sore throat with fever": "sore throat",
    "stiff neck": "back pain",
    "stiffness": "joint pain",
    "stomach pain": "abdominal pain",
    "tension headache": "headache",
    "tummy pain": "abdominal pain",
    "upper back pain": "back pain",
    "vomiting once": "vomiting",
    "vomiting with stomach pain": "vomiting",
    "weakness": "weakness",
    "wet cough": "cough",
    "wheezing": "wheezing",
    "wound": "wound",
    "body ache": "muscle pain",
    "muscle ache": "muscle pain",
    "throwing up": "vomiting",
    "being sick": "vomiting",
    "dizzy": "dizziness",
    "tired": "fatigue",
    "tiredness": "fatigue",
    "no appetite": "appetite loss",
    "not eating": "appetite loss",
    "blocked nose": "runny nose",
}

DICTIONARY_MEANING_TO_SYMPTOM = {
    "shortness of breath": ("asthma", "breathing difficulty", "difficulty breathing"),
    "abdominal pain": ("stomach ache", "stomach pain", "belly pain"),
    "diarrhea": ("diarrhoea", "diarrhea"),
    "dizziness": ("dizzy", "dizziness"),
    "fatigue": ("tired", "weary", "exhausted"),
    "fever": ("fever", "feverish"),
    "headache": ("headache",),
    "cough": ("cough", "coughs", "chest cold"),
    "nausea": ("nauseated", "feel sick", "like vomiting"),
    "rash": ("itchy", "spots on body"),
    "sore throat": ("sore throat",),
    "vomiting": ("vomit", "vomiting", "puke", "spew", "regurgitate"),
}

YOLNGU_TO_SYMPTOM = {
    "bambay": "blurred vision",
    "bäka": "muscle pain",
    "balkatj": "back pain",
    "bälim'bun": "fever",
    "bälimbun": "fever",
    "gurru": "headache",
    "ŋoy": "nausea",
    "ngoy": "nausea",
    "marrtji": "dizziness",
    "gämaŋ": "fatigue",
    "gämang": "fatigue",
    "garrtjarr": "cough",
    "nhäl": "blurred vision",
    "nhal": "blurred vision",
}


def preprocess_text(text):
    text = str(text or "").lower()
    text = re.sub(r"[^\w\s'äöüŋḏḻṉṱ-]", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def _add_unique(items, value):
    if value and value not in items:
        items.append(value)


def _meaning_text(entry):
    meaning = entry.get("meaning", "")
    if isinstance(meaning, list):
        return " ".join(str(item) for item in meaning)
    return str(meaning)


def _load_dictionary_symptom_map(vocabulary):
    global _DICTIONARY_SYMPTOM_MAP

    vocab = tuple(sorted(vocabulary or DEFAULT_SYMPTOMS))
    if _DICTIONARY_SYMPTOM_MAP and _DICTIONARY_SYMPTOM_MAP.get("vocab") == vocab:
        return _DICTIONARY_SYMPTOM_MAP["mapping"]

    mapping = {}
    if os.path.exists(YOLNGU_DICTIONARY_PATH):
        with open(YOLNGU_DICTIONARY_PATH, encoding="utf-8") as file:
            entries = json.load(file)

        for entry in entries:
            word = preprocess_text(entry.get("word", ""))
            if not word or word.lower() == "word":
                continue

            meaning = preprocess_text(_meaning_text(entry))
            for symptom, keywords in DICTIONARY_MEANING_TO_SYMPTOM.items():
                if symptom not in vocab:
                    continue
                if any(keyword in meaning for keyword in keywords):
                    mapping[word] = symptom
                    break

    _DICTIONARY_SYMPTOM_MAP = {"vocab": vocab, "mapping": mapping}
    return mapping


def extract_symptoms(text, lang_choice=1, vocabulary=None):
    cleaned = preprocess_text(text)
    if not cleaned:
        return []

    vocab = list(vocabulary or DEFAULT_SYMPTOMS)
    vocab_set = set(vocab)
    dictionary_map = _load_dictionary_symptom_map(vocab)
    matched = []

    for symptom in sorted(vocab, key=len, reverse=True):
        pattern = r"(?<!\w)" + re.escape(symptom) + r"(?!\w)"
        if re.search(pattern, cleaned):
            _add_unique(matched, symptom)

    for phrase, canonical in ENGLISH_SYNONYMS.items():
        if canonical in vocab_set and phrase in cleaned:
            _add_unique(matched, canonical)

    for word in cleaned.split():
        if word in STOPWORDS:
            continue
        mapped = YOLNGU_TO_SYMPTOM.get(word)
        if not mapped:
            mapped = dictionary_map.get(word)
        if mapped in vocab_set:
            _add_unique(matched, mapped)

    return matched


def has_yolngu_dictionary_word(text, vocabulary=None):
    cleaned = preprocess_text(text)
    dictionary_map = _load_dictionary_symptom_map(vocabulary or DEFAULT_SYMPTOMS)
    return any(word in dictionary_map for word in cleaned.split())


def translate_to_english(text):
    cleaned = preprocess_text(text)
    dictionary_map = _load_dictionary_symptom_map(DEFAULT_SYMPTOMS)
    words = [YOLNGU_TO_SYMPTOM.get(word) or dictionary_map.get(word) or word for word in cleaned.split()]
    return " ".join(words)
