"""
Train an app-focused symptom triage model.

The original dataset disease labels are weak for free-text symptom triage because
the same symptom combinations appear across unrelated diseases. This trainer
creates deterministic severity labels from symptom risk signals, then trains a
model that matches the API's real input: normalized symptoms only.
"""

from pathlib import Path
import json

import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, f1_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from xgboost import XGBClassifier


ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "Healthcare.csv"
MODELS_DIR = ROOT / "models"
APP_DIR = ROOT / "app_integration"
OUTPUTS_DIR = ROOT / "outputs"

LABELS = {0: "Mild", 1: "Moderate", 2: "Severe"}

SEVERE_SYMPTOMS = {
    "bleeding heavy",
    "chest pain",
    "confusion",
    "fainting",
    "numbness",
    "shortness of breath",
    "blurred vision",
    "tremors",
    "wheezing",
}

MODERATE_SYMPTOMS = {
    "bleeding",
    "bloating",
    "burn",
    "constipation",
    "ear pain",
    "eye pain",
    "fever",
    "vomiting",
    "diarrhea",
    "dizziness",
    "swelling",
    "sweating",
    "appetite loss",
    "weight loss",
    "fatigue",
    "insomnia",
    "depression",
    "anxiety",
    "skin infection",
    "skin redness",
    "weakness",
    "wound",
}

MILD_SYMPTOMS = {
    "runny nose",
    "sneezing",
    "sore throat",
    "cough",
    "rash",
    "itching",
    "headache",
    "back pain",
    "joint pain",
    "muscle pain",
    "weight gain",
}

EXTRA_APP_SYMPTOMS = sorted(
    {
        "arm pain",
        "bleeding",
        "bleeding heavy",
        "bloating",
        "burn",
        "confusion",
        "constipation",
        "ear pain",
        "eye pain",
        "fainting",
        "foot pain",
        "itching",
        "knee pain",
        "leg pain",
        "neck pain",
        "numbness",
        "shoulder pain",
        "skin infection",
        "skin redness",
        "weakness",
        "wheezing",
        "wound",
    }
)

GENDER_MAPPING = {"Male": 0, "Female": 1, "Other": 2}


def parse_symptoms(value):
    return [part.strip().lower() for part in str(value).split(",") if part.strip()]


def augment_with_app_symptoms(df):
    rows = []
    for symptom in EXTRA_APP_SYMPTOMS:
        for age, gender in ((30, "Other"), (45, "Female"), (60, "Male")):
            rows.append(
                {
                    "Patient_ID": -1,
                    "Age": age,
                    "Gender": gender,
                    "Symptoms": symptom,
                    "Symptom_Count": 1,
                    "Disease": "App Symptom",
                }
            )

    combo_rows = [
        "bleeding, wound",
        "bleeding heavy, wound",
        "burn, skin redness",
        "skin infection, swelling",
        "fainting, dizziness",
        "confusion, dizziness",
        "wheezing, shortness of breath",
        "eye pain, blurred vision",
        "ear pain, fever",
        "weakness, fatigue",
        "numbness, weakness",
    ]
    for symptoms in combo_rows:
        rows.append(
            {
                "Patient_ID": -1,
                "Age": 50,
                "Gender": "Other",
                "Symptoms": symptoms,
                "Symptom_Count": len(parse_symptoms(symptoms)),
                "Disease": "App Symptom Combo",
            }
        )

    return pd.concat([df, pd.DataFrame(rows)], ignore_index=True)


def symptom_triage_label(symptoms):
    symptom_set = set(symptoms)

    if symptom_set & SEVERE_SYMPTOMS:
        return 2

    if len(symptoms) >= 4 and symptom_set & {"vomiting", "diarrhea", "dizziness", "sweating"}:
        return 2

    if symptom_set & MODERATE_SYMPTOMS:
        return 1

    if len(symptoms) >= 4:
        return 1

    if symptom_set and symptom_set <= MILD_SYMPTOMS:
        return 0

    return 1


def build_features(df):
    symptom_lists = df["Symptoms"].apply(parse_symptoms)
    unique_symptoms = sorted(
        {symptom for symptoms in symptom_lists for symptom in symptoms}.union(EXTRA_APP_SYMPTOMS)
    )

    symptom_rows = []
    for symptoms in symptom_lists:
        symptom_set = set(symptoms)
        symptom_rows.append([1 if symptom in symptom_set else 0 for symptom in unique_symptoms])

    symptom_matrix = np.array(symptom_rows, dtype=np.float32)

    age_scaler = MinMaxScaler()
    age_normalized = age_scaler.fit_transform(df[["Age"]]).astype(np.float32)

    gender_encoded = (
        df["Gender"]
        .map(GENDER_MAPPING)
        .fillna(GENDER_MAPPING["Other"])
        .to_numpy(dtype=np.float32)
        .reshape(-1, 1)
    )

    symptom_count = np.array([len(symptoms) for symptoms in symptom_lists], dtype=np.float32)
    symptom_count_normalized = (symptom_count / max(len(unique_symptoms), 1)).reshape(-1, 1)

    X = np.hstack([symptom_matrix, age_normalized, gender_encoded, symptom_count_normalized])
    y = np.array([symptom_triage_label(symptoms) for symptoms in symptom_lists], dtype=np.int64)

    return X, y, unique_symptoms, age_scaler


def train_model(X_train, y_train):
    class_counts = np.bincount(y_train, minlength=3)
    sample_weight = np.array([len(y_train) / (3 * class_counts[label]) for label in y_train])

    model = XGBClassifier(
        objective="multi:softprob",
        num_class=3,
        n_estimators=450,
        max_depth=5,
        learning_rate=0.045,
        subsample=0.9,
        colsample_bytree=0.9,
        min_child_weight=2,
        reg_lambda=2.0,
        reg_alpha=0.15,
        eval_metric="mlogloss",
        random_state=42,
        n_jobs=-1,
    )
    model.fit(X_train, y_train, sample_weight=sample_weight)
    return model


def save_artifacts(model, preprocessing, X, y, X_val, y_val, X_test, y_test):
    MODELS_DIR.mkdir(exist_ok=True)
    APP_DIR.mkdir(exist_ok=True)
    OUTPUTS_DIR.mkdir(exist_ok=True)

    np.save(MODELS_DIR / "X_processed.npy", X)
    np.save(MODELS_DIR / "y_processed.npy", y)
    np.save(MODELS_DIR / "X_val.npy", X_val)
    np.save(MODELS_DIR / "y_val.npy", y_val)
    np.save(MODELS_DIR / "X_test.npy", X_test)
    np.save(MODELS_DIR / "y_test.npy", y_test)

    joblib.dump(preprocessing, MODELS_DIR / "preprocessing_objects.pkl")
    joblib.dump(preprocessing, APP_DIR / "preprocessing_objects.pkl")

    model.save_model(MODELS_DIR / "saca_triage_model_xgb.json")
    model.save_model(APP_DIR / "saca_triage_model_xgb.json")

    (MODELS_DIR / "best_model_name.txt").write_text("XGBoost", encoding="utf-8")
    (APP_DIR / "best_model_name.txt").write_text("XGBoost", encoding="utf-8")


def main():
    df = augment_with_app_symptoms(pd.read_csv(DATA_PATH))
    X, y, unique_symptoms, age_scaler = build_features(df)

    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.3, random_state=42, stratify=y
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
    )

    model = train_model(X_train, y_train)

    val_pred = model.predict(X_val)
    test_pred = model.predict(X_test)

    val_acc = accuracy_score(y_val, val_pred)
    val_f1 = f1_score(y_val, val_pred, average="macro")
    test_acc = accuracy_score(y_test, test_pred)
    test_f1 = f1_score(y_test, test_pred, average="macro")

    report = classification_report(
        y_test,
        test_pred,
        target_names=[LABELS[i] for i in range(3)],
        digits=4,
    )

    preprocessing = {
        "unique_symptoms": unique_symptoms,
        "age_scaler": age_scaler,
        "gender_mapping": GENDER_MAPPING,
        "labeling_strategy": "symptom_risk_rules_v1",
        "symptom_triage_rules": {
            "severe_symptoms": sorted(SEVERE_SYMPTOMS),
            "moderate_symptoms": sorted(MODERATE_SYMPTOMS),
            "mild_symptoms": sorted(MILD_SYMPTOMS),
        },
    }

    save_artifacts(model, preprocessing, X, y, X_val, y_val, X_test, y_test)

    (OUTPUTS_DIR / "classification_report.txt").write_text(
        "Best Model: XGBoost\n"
        "Labeling: symptom_risk_rules_v1\n\n"
        f"Validation Accuracy: {val_acc:.4f}\n"
        f"Validation Macro F1: {val_f1:.4f}\n"
        f"Test Accuracy: {test_acc:.4f}\n"
        f"Test Macro F1: {test_f1:.4f}\n\n"
        f"{report}",
        encoding="utf-8",
    )

    results = pd.DataFrame(
        {
            "Accuracy": [test_acc],
            "Precision": [np.nan],
            "Recall": [np.nan],
            "F1-Score": [test_f1],
        },
        index=["XGBoost"],
    )
    results.to_csv(OUTPUTS_DIR / "model_comparison_results.csv")

    diagnostics = {
        "dataset_rows": int(len(df)),
        "feature_count": int(X.shape[1]),
        "unique_symptoms": int(len(unique_symptoms)),
        "class_distribution": {LABELS[i]: int((y == i).sum()) for i in range(3)},
        "validation_accuracy": val_acc,
        "validation_macro_f1": val_f1,
        "test_accuracy": test_acc,
        "test_macro_f1": test_f1,
        "confusion_matrix": confusion_matrix(y_test, test_pred).tolist(),
    }
    (OUTPUTS_DIR / "symptom_triage_training_metrics.json").write_text(
        json.dumps(diagnostics, indent=2),
        encoding="utf-8",
    )

    print("=" * 60)
    print("SACA SYMPTOM TRIAGE XGBOOST TRAINING COMPLETE")
    print("=" * 60)
    print(f"Rows: {len(df)}")
    print(f"Features: {X.shape[1]} ({len(unique_symptoms)} symptoms + age/gender/count)")
    print(f"Class distribution: {diagnostics['class_distribution']}")
    print(f"Validation Accuracy: {val_acc:.4f}")
    print(f"Validation Macro F1: {val_f1:.4f}")
    print(f"Test Accuracy: {test_acc:.4f}")
    print(f"Test Macro F1: {test_f1:.4f}")
    print("\n" + report)
    print("[OK] Exported model to models/ and app_integration/")


if __name__ == "__main__":
    main()
