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
    "abdominal pain", "anxiety", "appetite loss", "back pain",
    "blurred vision", "chest pain", "cough", "depression", "diarrhea",
    "dizziness", "fatigue", "fever", "headache", "insomnia",
    "joint pain", "muscle pain", "nausea", "rash", "runny nose",
    "shortness of breath", "sneezing", "sore throat", "sweating",
    "swelling", "tremors", "vomiting", "weight gain", "weight loss",
]

ENGLISH_SYNONYMS = {
    "belly pain": "abdominal pain",
    "stomach pain": "abdominal pain",
    "tummy pain": "abdominal pain",
    "breathing difficulty": "shortness of breath",
    "difficulty breathing": "shortness of breath",
    "can't breathe": "shortness of breath",
    "cant breathe": "shortness of breath",
    "sore back": "back pain",
    "body pain": "muscle pain",
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
