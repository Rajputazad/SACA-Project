import os
import sys
import warnings
from collections import Counter, defaultdict
from typing import Dict, List, Optional, Tuple
import csv

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
NLP_DIR = os.path.join(PROJECT_DIR, "nlp")
APP_INTEGRATION_DIR = os.path.join(PROJECT_DIR, "app_integration")
NLP_MODEL_DIR = os.path.join(NLP_DIR, "model")
DATA_PATH = os.path.join(PROJECT_DIR, "data", "Healthcare.csv")

for path in (PROJECT_DIR, NLP_DIR):
    if path not in sys.path:
        sys.path.append(path)

from app_integration.saca_ml_inference import SACATriageModel
from nlp_processing import extract_symptoms, has_yolngu_dictionary_word, translate_to_english


LANGUAGE_ALIASES = {
    "en": "english",
    "eng": "english",
    "english": "english",
    "yo": "yolngu",
    "yolngu": "yolngu",
    "yolngu matha": "yolngu",
    "auto": "auto",
}

RED_FLAG_SYMPTOMS = {
    "bleeding heavy",
    "chest pain",
    "confusion",
    "fainting",
    "numbness",
    "shortness of breath",
    "wheezing",
}

RAW_SEVERE_PHRASES = (
    "heavy bleeding",
    "bleeding with pain",
    "fainting",
    "confusion",
    "numbness",
    "severe injury",
    "unconscious",
    "not breathing",
)

RAW_MODERATE_PHRASES = (
    "small bleeding",
    "bleeding",
    "wound",
    "burning skin",
    "skin infection",
    "ear pain",
    "eye pain",
    "weakness",
    "wheezing",
    "repeated vomiting",
    "high fever",
)

CONDITION_PROFILES = {
    "Common Cold": {"runny nose", "sneezing", "sore throat", "cough"},
    "Influenza": {"fever", "cough", "fatigue", "muscle pain", "headache", "sore throat"},
    "COVID-19": {"fever", "cough", "fatigue", "shortness of breath", "sore throat"},
    "Bronchitis": {"cough", "shortness of breath", "wheezing", "chest pain", "fatigue"},
    "Asthma": {"shortness of breath", "wheezing", "cough", "chest pain"},
    "Pneumonia": {"fever", "cough", "shortness of breath", "chest pain", "fatigue"},
    "Tuberculosis": {"cough", "fever", "sweating", "weight loss", "fatigue"},
    "Migraine": {"headache", "nausea", "blurred vision", "eye pain"},
    "Sinusitis": {"headache", "runny nose", "sore throat", "cough"},
    "Food Poisoning": {"vomiting", "diarrhea", "nausea", "abdominal pain", "fever"},
    "Gastritis": {"abdominal pain", "nausea", "vomiting", "appetite loss"},
    "IBS": {"abdominal pain", "diarrhea", "bloating", "constipation"},
    "Allergy": {"rash", "itching", "swelling", "runny nose", "sneezing"},
    "Dermatitis": {"rash", "itching", "skin redness", "swelling"},
    "Skin Infection": {"skin infection", "skin redness", "swelling", "wound", "fever"},
    "Burn Injury": {"burn", "skin redness", "swelling"},
    "Open Wound / Bleeding Injury": {"bleeding", "bleeding heavy", "wound"},
    "Anemia": {"fatigue", "dizziness", "weakness", "shortness of breath"},
    "Anxiety": {"anxiety", "chest pain", "shortness of breath", "sweating", "tremors"},
    "Depression": {"depression", "fatigue", "insomnia", "appetite loss"},
    "Heart Disease": {"chest pain", "shortness of breath", "sweating", "fatigue"},
    "Stroke Warning Signs": {"confusion", "numbness", "blurred vision", "dizziness", "weakness"},
    "Ear Infection": {"ear pain", "fever", "dizziness"},
    "Eye Irritation / Eye Infection": {"eye pain", "blurred vision", "skin redness"},
    "Arthritis": {"joint pain", "swelling", "stiffness", "knee pain"},
}


class TriageService:
    def __init__(self):
        self.model, self.model_source, self.model_error = self._load_model()
        self.condition_index = self._load_condition_index()

    def _load_model(self) -> Tuple[Optional[SACATriageModel], str, Optional[str]]:
        candidates = [
            (APP_INTEGRATION_DIR, "app_integration"),
            (NLP_MODEL_DIR, "nlp/model Random Forest fallback"),
        ]

        last_error = None
        for model_dir, label in candidates:
            try:
                return SACATriageModel(model_dir=model_dir), label, None
            except Exception as exc:
                last_error = f"{label}: {exc}"

        return None, "rule_based_fallback", last_error

    def _load_condition_index(self) -> Dict[str, Dict]:
        if not os.path.exists(DATA_PATH):
            return {}

        condition_rows = defaultdict(list)
        symptom_counts = defaultdict(Counter)

        with open(DATA_PATH, newline="", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            for row in reader:
                condition = str(row.get("Disease", "")).strip()
                raw_symptoms = str(row.get("Symptoms", ""))
                if not condition or not raw_symptoms:
                    continue

                symptoms = {
                    symptom.strip().lower()
                    for symptom in raw_symptoms.split(",")
                    if symptom.strip()
                }
                if not symptoms:
                    continue

                condition_rows[condition].append(symptoms)
                symptom_counts[condition].update(symptoms)

        index = {}
        for condition, rows in condition_rows.items():
            common = [symptom for symptom, _ in symptom_counts[condition].most_common(8)]
            index[condition] = {
                "rows": rows,
                "common_symptoms": common,
                "row_count": len(rows),
            }

        return index

    @property
    def symptom_vocabulary(self) -> List[str]:
        if self.model:
            return list(self.model.unique_symptoms)
        return []

    def _detect_language(self, text: str, requested_language: str) -> str:
        requested = LANGUAGE_ALIASES.get(str(requested_language or "auto").strip().lower(), "auto")
        if requested != "auto":
            return requested

        lowered = text.lower()
        yolngu_markers = ("ŋ", "ḏ", "ḻ", "ṉ", "ṱ", "ä", "bälim", "gurru", "ŋoy", "nhäl")
        if any(marker in lowered for marker in yolngu_markers):
            return "yolngu"
        if has_yolngu_dictionary_word(text, self.symptom_vocabulary):
            return "yolngu"
        return "english"

    def _empty_response(self, text: str, detected_language: str, processed_text: str) -> Dict:
        return {
            "input_text": text,
            "detected_language": detected_language,
            "processed_text": processed_text,
            "input_symptoms": [],
            "predicted_severity": "Unknown",
            "triage_level": None,
            "confidence": {},
            "possible_conditions": [],
            "suggestion": "Please enter clearer symptoms, for example: fever and cough, chest pain, vomiting, headache.",
            "important_details": [
                "No known symptoms were matched from the trained model vocabulary.",
                "This tool is support for triage only and does not replace a clinician.",
            ],
            "model_used": self.model_source,
        }

    def _possible_conditions(self, symptoms: List[str], limit: int = 5) -> List[Dict]:
        if not symptoms:
            return []

        symptom_set = set(symptoms)
        ranked = []
        seen_conditions = set()

        if self.condition_index:
            for condition, data in self.condition_index.items():
                exact_matches = [
                    row_symptoms
                    for row_symptoms in data["rows"]
                    if row_symptoms == symptom_set
                ]
                if not exact_matches:
                    continue

                ranked.append(
                    {
                        "condition": condition,
                        "match_score": 1.0,
                        "matched_symptoms": sorted(symptom_set),
                        "common_symptoms": data["common_symptoms"],
                        "note": "Exact symptom set found in the training dataset; possible condition only, not a diagnosis.",
                    }
                )
                seen_conditions.add(condition)

        for condition, profile in CONDITION_PROFILES.items():
            if condition in seen_conditions:
                continue

            matched = symptom_set.intersection(profile)
            if not matched:
                continue

            input_coverage = len(matched) / max(len(symptom_set), 1)
            profile_coverage = len(matched) / max(len(profile), 1)
            score = min((input_coverage * 0.75) + (profile_coverage * 0.25), 1.0)
            ranked.append(
                {
                    "condition": condition,
                    "match_score": round(score, 3),
                    "matched_symptoms": sorted(matched),
                    "common_symptoms": sorted(profile),
                    "note": "Possible condition based on symptom profile matching; not a diagnosis.",
                }
            )
            seen_conditions.add(condition)

        if ranked:
            ranked.sort(
                key=lambda item: (
                    item["match_score"],
                    len(item["matched_symptoms"]),
                    item["condition"],
                ),
                reverse=True,
            )
            return ranked[:limit]

        if not self.condition_index:
            return []

        for condition, data in self.condition_index.items():
            if condition in seen_conditions:
                continue

            best_matched = set()
            best_ratio = 0.0

            for row_symptoms in data["rows"]:
                matched = symptom_set.intersection(row_symptoms)
                if not matched:
                    continue

                ratio = len(matched) / max(len(symptom_set), 1)
                if ratio > best_ratio or len(matched) > len(best_matched):
                    best_ratio = ratio
                    best_matched = matched

            if not best_matched:
                continue

            support = min(data["row_count"] / 900, 1.0)
            score = min((best_ratio * 0.55) + (support * 0.1), 0.65)
            ranked.append(
                {
                    "condition": condition,
                    "match_score": round(score, 3),
                    "matched_symptoms": sorted(best_matched),
                    "common_symptoms": data["common_symptoms"],
                    "note": "Possible condition based on symptom overlap in the training dataset; not a diagnosis.",
                }
            )

        ranked.sort(
            key=lambda item: (
                item["match_score"],
                len(item["matched_symptoms"]),
                item["condition"],
            ),
            reverse=True,
        )
        return ranked[:limit]

    def _rule_based_prediction(self, symptoms: List[str]) -> Dict:
        if RED_FLAG_SYMPTOMS.intersection(symptoms):
            severity, level = "Severe", 3
        elif len(symptoms) >= 2 or any(symptom in symptoms for symptom in ("fever", "vomiting", "dizziness")):
            severity, level = "Moderate", 2
        else:
            severity, level = "Mild", 1

        confidence = {"Mild": 0.0, "Moderate": 0.0, "Severe": 0.0}
        confidence[severity] = 1.0
        suggestions = {
            "Mild": "Use self-care, rest, drink fluids, and monitor symptoms.",
            "Moderate": "Book a healthcare appointment within 24-48 hours or sooner if symptoms worsen.",
            "Severe": "Seek urgent medical care now. Call emergency services if breathing, chest pain, confusion, or collapse is present.",
        }
        return {
            "input_symptoms": symptoms,
            "triage_level": level,
            "triage_label": severity,
            "confidence": confidence,
            "recommendation": suggestions[severity],
        }

    def _apply_safety_overrides(self, result: Dict, symptoms: List[str], raw_text: str) -> Dict:
        raw = raw_text.lower()
        red_flags = RED_FLAG_SYMPTOMS.intersection(symptoms)
        has_raw_severe = any(phrase in raw for phrase in RAW_SEVERE_PHRASES)
        has_raw_moderate = any(phrase in raw for phrase in RAW_MODERATE_PHRASES)

        if not red_flags and not has_raw_severe:
            if has_raw_moderate and result.get("triage_level", 1) < 2:
                result = dict(result)
                result["triage_level"] = 2
                result["triage_label"] = "Moderate"
                result["confidence"] = {"Mild": 0.05, "Moderate": 0.9, "Severe": 0.05}
                result["recommendation"] = (
                    "Consult a healthcare provider within 24-48 hours. Seek urgent care sooner "
                    "if bleeding, pain, swelling, breathing, or weakness gets worse."
                )
            return result

        result = dict(result)
        result["triage_level"] = 3
        result["triage_label"] = "Severe"
        result["confidence"] = {"Mild": 0.0, "Moderate": 0.05, "Severe": 0.95}
        result["recommendation"] = (
            "Seek urgent medical care now. Call emergency services if chest pain, "
            "trouble breathing, collapse, confusion, or severe bleeding is present."
        )
        return result

    def predict(self, text: str, language: str = "auto") -> Dict:
        detected_language = self._detect_language(text, language)
        lang_choice = 2 if detected_language == "yolngu" else 1
        processed_text = translate_to_english(text) if detected_language == "yolngu" else text
        symptoms = extract_symptoms(processed_text, lang_choice=lang_choice, vocabulary=self.symptom_vocabulary)

        if not symptoms:
            symptoms = extract_symptoms(text, lang_choice=lang_choice, vocabulary=self.symptom_vocabulary)

        if not symptoms:
            return self._empty_response(text, detected_language, processed_text)

        if self.model:
            with warnings.catch_warnings():
                warnings.filterwarnings("ignore", message="X does not have valid feature names")
                result = self.model.predict_from_symptoms(symptoms, age=30, gender="Other")
        else:
            result = self._rule_based_prediction(symptoms)

        result = self._apply_safety_overrides(result, symptoms, text)

        important_details = [
            "Matched symptoms are normalized to the trained model vocabulary.",
            "For emergency warning signs such as chest pain, trouble breathing, collapse, or severe bleeding, seek urgent care immediately.",
        ]
        if self.model_error:
            important_details.append(f"Model fallback note: {self.model_error}")

        return {
            "input_text": text,
            "detected_language": detected_language,
            "processed_text": processed_text,
            "input_symptoms": result["input_symptoms"],
            "predicted_severity": result["triage_label"],
            "triage_level": result["triage_level"],
            "confidence": result["confidence"],
            "possible_conditions": self._possible_conditions(result["input_symptoms"]),
            "suggestion": result["recommendation"],
            "important_details": important_details,
            "model_used": self.model_source,
        }
