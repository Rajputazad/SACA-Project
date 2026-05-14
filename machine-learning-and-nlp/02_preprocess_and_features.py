"""
SACA ML Project - Part 2: Preprocess Data and Create Features
"""

import os
import joblib
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, "data", "Healthcare.csv")
MODELS_DIR = os.path.join(BASE_DIR, "models")

os.makedirs(MODELS_DIR, exist_ok=True)

def create_triage_labels(df):
    disease_to_triage = {
        "Common Cold": 1, "Allergy": 1, "Dermatitis": 1, "Sinusitis": 1,
        "Bronchitis": 1, "Food Poisoning": 1, "Gastritis": 1, "Ulcer": 1,
        "Anemia": 1, "Thyroid Disorder": 1, "Obesity": 1, "Depression": 1,
        "Anxiety": 1, "Migraine": 1,

        "Influenza": 2, "Asthma": 2, "Epilepsy": 2, "Arthritis": 2,
        "Diabetes": 2, "Hypertension": 2, "Irritable Bowel Syndrome (IBS)": 2,
        "Liver Disease": 2, "Chronic Kidney Disease": 2,

        "COVID-19": 3, "Pneumonia": 3, "Tuberculosis": 3,
        "Heart Disease": 3, "Stroke": 3, "Dementia": 3, "Parkinson's Disease": 3,
    }

    df["Triage_Level"] = df["Disease"].map(disease_to_triage).fillna(2).astype(int)

    print("\nTriage distribution:")
    for level, label in [(1, "Mild"), (2, "Moderate"), (3, "Severe")]:
        count = (df["Triage_Level"] == level).sum()
        print(f"Level {level} ({label}): {count}")

    return df, disease_to_triage

def extract_symptom_features(df):
    all_symptoms = []

    for symptom_text in df["Symptoms"]:
        symptoms = [s.strip().lower() for s in str(symptom_text).split(",") if s.strip()]
        all_symptoms.extend(symptoms)

    unique_symptoms = sorted(set(all_symptoms))
    print(f"\n[OK] Found {len(unique_symptoms)} unique symptoms")

    rows = []
    for symptom_text in df["Symptoms"]:
        symptoms = set(s.strip().lower() for s in str(symptom_text).split(",") if s.strip())
        rows.append([1 if symptom in symptoms else 0 for symptom in unique_symptoms])

    symptom_df = pd.DataFrame(rows, columns=unique_symptoms)
    return symptom_df, unique_symptoms

def preprocess_data(df, symptom_df):
    gender_mapping = {"Male": 0, "Female": 1, "Other": 2}
    df["Gender_Encoded"] = df["Gender"].map(gender_mapping).fillna(2).astype(int)

    age_scaler = MinMaxScaler()
    df["Age_Normalized"] = age_scaler.fit_transform(df[["Age"]])

    if "Symptom_Count" not in df.columns:
        df["Symptom_Count"] = df["Symptoms"].apply(
            lambda x: len([s for s in str(x).split(",") if s.strip()])
        )

    max_symptom_count = max(df["Symptom_Count"].max(), 1)
    df["Symptom_Count_Normalized"] = df["Symptom_Count"] / max_symptom_count

    X = np.hstack([
        symptom_df.values,
        df[["Age_Normalized", "Gender_Encoded", "Symptom_Count_Normalized"]].values
    ])

    y = df["Triage_Level"].values - 1

    print(f"[OK] Feature matrix shape: {X.shape}")
    print(f"[OK] Target shape: {y.shape}")

    return X, y, age_scaler, gender_mapping

def main():
    print("=" * 60)
    print("PART 2: PREPROCESSING AND FEATURE ENGINEERING")
    print("=" * 60)

    df = pd.read_csv(DATA_PATH)

    df, disease_mapping = create_triage_labels(df)
    symptom_df, unique_symptoms = extract_symptom_features(df)
    X, y, age_scaler, gender_mapping = preprocess_data(df, symptom_df)

    preprocessing_dict = {
        "unique_symptoms": unique_symptoms,
        "age_scaler": age_scaler,
        "gender_mapping": gender_mapping,
        "disease_to_triage": disease_mapping,
    }

    joblib.dump(preprocessing_dict, os.path.join(MODELS_DIR, "preprocessing_objects.pkl"))
    np.save(os.path.join(MODELS_DIR, "X_processed.npy"), X)
    np.save(os.path.join(MODELS_DIR, "y_processed.npy"), y)

    print("[OK] Saved preprocessing objects and processed arrays.")
    return X, y

if __name__ == "__main__":
    main()