import os
import sys
import warnings
from typing import Dict, List, Optional, Tuple

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
NLP_DIR = os.path.join(PROJECT_DIR, "nlp")
APP_INTEGRATION_DIR = os.path.join(PROJECT_DIR, "app_integration")
NLP_MODEL_DIR = os.path.join(NLP_DIR, "model")

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
    "chest pain",
    "shortness of breath",
}


class TriageService:
    def __init__(self):
        self.model, self.model_source, self.model_error = self._load_model()

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
            "suggestion": "Please enter clearer symptoms, for example: fever and cough, chest pain, vomiting, headache.",
            "important_details": [
                "No known symptoms were matched from the trained model vocabulary.",
                "This tool is support for triage only and does not replace a clinician.",
            ],
            "model_used": self.model_source,
        }

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

    def _apply_safety_overrides(self, result: Dict, symptoms: List[str]) -> Dict:
        red_flags = RED_FLAG_SYMPTOMS.intersection(symptoms)
        if not red_flags:
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

        result = self._apply_safety_overrides(result, symptoms)

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
            "suggestion": result["recommendation"],
            "important_details": important_details,
            "model_used": self.model_source,
        }
