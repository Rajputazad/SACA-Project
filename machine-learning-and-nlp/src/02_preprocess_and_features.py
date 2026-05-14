"""
SACA ML Project - Part 2: Preprocess Data and Create Features
"""

import pandas as pd
import numpy as np
import joblib
from sklearn.preprocessing import MinMaxScaler
import os

os.makedirs('../models', exist_ok=True)

def create_triage_labels(df):
    """Map diseases to triage severity levels"""
    
    disease_to_triage = {
        # MILD (Level 1)
        'Common Cold': 1, 'Allergy': 1, 'Dermatitis': 1, 'Sinusitis': 1,
        'Bronchitis': 1, 'Food Poisoning': 1, 'Gastritis': 1, 'Ulcer': 1,
        'Anemia': 1, 'Thyroid Disorder': 1, 'Obesity': 1, 'Depression': 1, 
        'Anxiety': 1, 'Migraine': 1,
        
        # MODERATE (Level 2)
        'Influenza': 2, 'Asthma': 2, 'Epilepsy': 2, 'Arthritis': 2, 
        'Diabetes': 2, 'Hypertension': 2, 'Irritable Bowel Syndrome (IBS)': 2,
        'Liver Disease': 2, 'Chronic Kidney Disease': 2,
        
        # SEVERE (Level 3)
        'COVID-19': 3, 'Pneumonia': 3, 'Tuberculosis': 3,
        'Heart Disease': 3, 'Stroke': 3, 'Dementia': 3, "Parkinson's Disease": 3
    }
    
    df['Triage_Level'] = df['Disease'].map(disease_to_triage)
    df['Triage_Level'] = df['Triage_Level'].fillna(2).astype(int)
    
    print("\n[DATA] Triage Level Distribution:")
    for level in [1, 2, 3]:
        count = (df['Triage_Level'] == level).sum()
        label = ['Mild', 'Moderate', 'Severe'][level-1]
        print(f"   Level {level} ({label}): {count} ({count/len(df)*100:.1f}%)")
    
    return df, disease_to_triage

def extract_symptom_features(df):
    """Extract binary features from symptoms"""
    
    all_symptoms = []
    for symptoms_list in df['Symptoms']:
        symptoms = [s.strip().lower() for s in str(symptoms_list).split(',')]
        all_symptoms.extend(symptoms)
    
    unique_symptoms = sorted(list(set(all_symptoms)))
    print(f"\n[OK] Found {len(unique_symptoms)} unique symptoms")
    
    # Create binary matrix
    symptom_matrix = []
    for symptoms_list in df['Symptoms']:
        symptoms = [s.strip().lower() for s in str(symptoms_list).split(',')]
        row = [1 if symptom in symptoms else 0 for symptom in unique_symptoms]
        symptom_matrix.append(row)
    
    symptom_df = pd.DataFrame(symptom_matrix, columns=unique_symptoms)
    
    return symptom_df, unique_symptoms

def preprocess_data(df, symptom_df):
    """Preprocess all features"""
    
    # Encode gender
    gender_mapping = {'Male': 0, 'Female': 1, 'Other': 2}
    df['Gender_Encoded'] = df['Gender'].map(gender_mapping).fillna(2)
    
    # Normalize age
    age_scaler = MinMaxScaler()
    df['Age_Normalized'] = age_scaler.fit_transform(df[['Age']])
    
    # Normalize symptom count
    df['Symptom_Count_Normalized'] = df['Symptom_Count'] / df['Symptom_Count'].max()
    
    # Combine features
    X = np.hstack([
        symptom_df.values,
        df[['Age_Normalized', 'Gender_Encoded', 'Symptom_Count_Normalized']].values
    ])
    
    y = df['Triage_Level'].values - 1  # Convert to 0,1,2
    
    print(f"\n[OK] Feature matrix shape: {X.shape}")
    print(f"[OK] Target shape: {y.shape}")
    
    return X, y, age_scaler, gender_mapping

def main():
    print("="*60)
    print("PART 2: PREPROCESSING AND FEATURE ENGINEERING")
    print("="*60)
    
    # Load data
    df = pd.read_csv('../data/Healthcare.csv')
    print(f"\nLoaded {len(df)} records")
    
    # Create triage labels
    df, disease_mapping = create_triage_labels(df)
    
    # Extract symptom features
    symptom_df, unique_symptoms = extract_symptom_features(df)
    
    # Preprocess all data
    X, y, age_scaler, gender_mapping = preprocess_data(df, symptom_df)
    
    # Save preprocessing objects
    preprocessing_dict = {
        'unique_symptoms': unique_symptoms,
        'age_scaler': age_scaler,
        'gender_mapping': gender_mapping,
        'disease_to_triage': disease_mapping
    }
    
    joblib.dump(preprocessing_dict, '../models/preprocessing_objects.pkl')
    print("\n[OK] Saved preprocessing objects to 'models/preprocessing_objects.pkl'")
    
    # Save processed data
    np.save('../models/X_processed.npy', X)
    np.save('../models/y_processed.npy', y)
    print("[OK] Saved processed data: X_processed.npy, y_processed.npy")
    
    return X, y

if __name__ == "__main__":
    X, y = main()