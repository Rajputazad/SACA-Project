"""
SACA ML Project - Part 7: Create Inference Module for App Integration / Local Testing
"""

import os
import shutil
import textwrap

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")
APP_DIR = os.path.join(BASE_DIR, "app_integration")

os.makedirs(APP_DIR, exist_ok=True)

def create_inference_module():
    print("=" * 60)
    print("PART 7: CREATING INFERENCE MODULE")
    print("=" * 60)

    inference_code = textwrap.dedent('''\
    """
    SACA ML Inference Module
    """

    import os
    import joblib
    import numpy as np


    class SACATriageModel:
        def __init__(self, model_dir="."):
            self.model_dir = model_dir
            self.preprocessors = self._load_preprocessors()
            self.unique_symptoms = self.preprocessors["unique_symptoms"]
            self.age_scaler = self.preprocessors["age_scaler"]
            self.gender_mapping = self.preprocessors["gender_mapping"]

            self.best_model_name = self._load_best_model_name()
            self.model, self.model_type = self._load_model()

            print(f"[OK] Loaded model: {self.best_model_name}")

        def _path(self, filename):
            return os.path.join(self.model_dir, filename)

        def _load_preprocessors(self):
            path = self._path("preprocessing_objects.pkl")
            if not os.path.exists(path):
                raise FileNotFoundError(f"Missing file: {path}")
            return joblib.load(path)

        def _load_best_model_name(self):
            path = self._path("best_model_name.txt")
            if not os.path.exists(path):
                return "Random Forest"

            with open(path, "r", encoding="utf-8") as f:
                name = f.read().strip()

            return name if name else "Random Forest"

        def _load_model(self):
            if self.best_model_name == "Random Forest":
                path = self._path("saca_triage_model_rf.pkl")
                if not os.path.exists(path):
                    raise FileNotFoundError(f"Missing file: {path}")
                return joblib.load(path), "sklearn"

            if self.best_model_name == "XGBoost":
                path = self._path("saca_triage_model_xgb.json")
                if not os.path.exists(path):
                    raise FileNotFoundError(f"Missing file: {path}")
                import xgboost as xgb
                model = xgb.XGBClassifier()
                model.load_model(path)
                return model, "xgboost"

            if self.best_model_name == "Neural Network":
                path = self._path("saca_triage_model_nn.h5")
                if not os.path.exists(path):
                    raise FileNotFoundError(f"Missing file: {path}")
                import tensorflow as tf
                return tf.keras.models.load_model(path), "tensorflow"

            raise ValueError(f"Unsupported model name: {self.best_model_name}")

        def _clean_symptoms(self, symptoms):
            if isinstance(symptoms, str):
                if "," in symptoms:
                    symptoms_list = [s.strip().lower() for s in symptoms.split(",")]
                else:
                    symptoms_list = [s.strip().lower() for s in symptoms.split()]
            elif isinstance(symptoms, list):
                symptoms_list = [str(s).strip().lower() for s in symptoms]
            else:
                symptoms_list = []

            return [s for s in symptoms_list if s]

        def _prepare_features(self, symptoms_list, age=30, gender="Other"):
            symptoms_list = self._clean_symptoms(symptoms_list)
            symptom_set = set(symptoms_list)

            symptom_vector = [
                1 if symptom in symptom_set else 0
                for symptom in self.unique_symptoms
            ]

            try:
                age = float(age)
            except Exception:
                age = 30.0

            age = max(1, min(90, age))
            age_normalized = self.age_scaler.transform([[age]])[0][0]
            gender_encoded = self.gender_mapping.get(str(gender).strip(), 2)
            symptom_count_normalized = len(symptoms_list) / max(len(self.unique_symptoms), 1)

            features = np.array(
                symptom_vector + [age_normalized, gender_encoded, symptom_count_normalized],
                dtype=float
            ).reshape(1, -1)

            return features, symptoms_list

        def predict_from_symptoms(self, symptoms_list, age=30, gender="Other"):
            features, cleaned_symptoms = self._prepare_features(symptoms_list, age, gender)

            if self.model_type in ["sklearn", "xgboost"]:
                prediction = self.model.predict(features)[0]
                probabilities = self.model.predict_proba(features)[0]
            else:
                pred_proba = self.model.predict(features, verbose=0)
                prediction = int(np.argmax(pred_proba, axis=1)[0])
                probabilities = pred_proba[0]

            triage_level = int(prediction) + 1
            triage_labels = {1: "Mild", 2: "Moderate", 3: "Severe"}

            recommendations = {
                1: "Self-care at home. Rest and stay hydrated. Monitor symptoms.",
                2: "Consult a healthcare provider within 24-48 hours.",
                3: "Seek immediate medical attention. Contact emergency services."
            }

            return {
                "input_symptoms": cleaned_symptoms,
                "age": age,
                "gender": gender,
                "triage_level": triage_level,
                "triage_label": triage_labels[triage_level],
                "confidence": {
                    "Mild": float(probabilities[0]),
                    "Moderate": float(probabilities[1]),
                    "Severe": float(probabilities[2]),
                },
                "recommendation": recommendations[triage_level]
            }

        def predict(self, symptoms_text, age=30, gender="Other"):
            return self.predict_from_symptoms(symptoms_text, age, gender)


    if __name__ == "__main__":
        print("=" * 60)
        print("Testing ML Inference Module")
        print("=" * 60)

        ml = SACATriageModel()

        test_cases = [
            (["runny nose", "sneezing", "cough"], 25, "Female"),
            (["fever", "cough", "fatigue"], 45, "Male"),
            (["chest pain", "shortness of breath"], 65, "Male"),
        ]

        for symptoms, age, gender in test_cases:
            result = ml.predict_from_symptoms(symptoms, age, gender)
            print(f"\\nSymptoms: {symptoms}")
            print(f"Age: {age}, Gender: {gender}")
            print(f"Triage: {result['triage_label']}")
            print(f"Confidence: {result['confidence'][result['triage_label']]:.2%}")

        print("\\n[OK] Module ready.")
    ''')

    inference_path = os.path.join(APP_DIR, "saca_ml_inference.py")
    with open(inference_path, "w", encoding="utf-8") as f:
        f.write(inference_code)

    files_to_copy = [
        "preprocessing_objects.pkl",
        "best_model_name.txt",
        "saca_triage_model_rf.pkl",
        "saca_triage_model_xgb.json",
        "saca_triage_model_nn.h5",
    ]

    for filename in files_to_copy:
        src = os.path.join(MODELS_DIR, filename)
        dst = os.path.join(APP_DIR, filename)
        if os.path.exists(src):
            shutil.copy(src, dst)
            print(f"Copied: {filename}")

    print("\n[OK] Inference package prepared in app_integration/")

if __name__ == "__main__":
    create_inference_module()