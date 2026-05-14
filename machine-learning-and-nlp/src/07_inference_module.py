"""
SACA ML Project - Part 7: Create Inference Module for App Integration
"""

import numpy as np
import joblib
import os

os.makedirs('../app_integration', exist_ok=True)

def create_inference_module():
    print("="*60)
    print("PART 7: CREATING INFERENCE MODULE")
    print("="*60)
    
    # Load preprocessing objects
    preprocessors = joblib.load('../models/preprocessing_objects.pkl')
    
    # Get best model
    try:
        with open('../models/best_model_name.txt', 'r') as f:
            best_model_name = f.read().strip()
    except:
        best_model_name = 'Random Forest'
    
    print(f"\nBest model: {best_model_name}")
    
    # Create inference code WITHOUT emojis
    inference_code = '''"""
SACA ML Inference Module
Compatible with NLP module for symptom analysis
"""

import numpy as np
import joblib
import os

class SACATriageModel:
    """ML Triage Classifier for SACA System"""
    
    def __init__(self, model_path='./'):
        # Load preprocessing objects
        self.preprocessors = joblib.load(f'{model_path}preprocessing_objects.pkl')
        self.unique_symptoms = self.preprocessors['unique_symptoms']
        self.age_scaler = self.preprocessors['age_scaler']
        self.gender_mapping = self.preprocessors['gender_mapping']
        
        # Load best model
        try:
            with open(f'{model_path}best_model_name.txt', 'r') as f:
                self.best_model_name = f.read().strip()
        except:
            self.best_model_name = 'Random Forest'
        
        if self.best_model_name == 'Random Forest':
            self.model = joblib.load(f'{model_path}saca_triage_model_rf.pkl')
            self.model_type = 'sklearn'
        elif self.best_model_name == 'XGBoost':
            import xgboost as xgb
            self.model = xgb.XGBClassifier()
            self.model.load_model(f'{model_path}saca_triage_model_xgb.json')
            self.model_type = 'xgboost'
        else:
            import tensorflow as tf
            self.model = tf.keras.models.load_model(f'{model_path}saca_triage_model_nn.h5')
            self.model_type = 'tensorflow'
        
        print(f"[OK] ML Model loaded: {self.best_model_name}")
    
    def predict_from_symptoms(self, symptoms_list, age=30, gender='Other'):
        """
        Predict triage level from symptoms
        
        Parameters:
        -----------
        symptoms_list : list of str
            List of symptoms (e.g., ['fever', 'cough'])
        age : int
            Patient's age (1-90)
        gender : str
            'Male', 'Female', or 'Other'
        
        Returns:
        --------
        dict with triage_level, triage_label, confidence, recommendation
        """
        
        # Create feature vector
        symptom_vector = [1 if symptom.lower() in symptoms_list else 0 
                         for symptom in self.unique_symptoms]
        
        age_normalized = self.age_scaler.transform([[age]])[0][0]
        gender_encoded = self.gender_mapping.get(gender, 2)
        symptom_count_normalized = len(symptoms_list) / len(self.unique_symptoms)
        
        features = np.array(symptom_vector + [
            age_normalized, gender_encoded, symptom_count_normalized
        ]).reshape(1, -1)
        
        # Predict
        if self.model_type == 'sklearn':
            prediction = self.model.predict(features)[0]
            probabilities = self.model.predict_proba(features)[0]
        elif self.model_type == 'xgboost':
            prediction = self.model.predict(features)[0]
            probabilities = self.model.predict_proba(features)[0]
        else:
            pred_proba = self.model.predict(features, verbose=0)
            prediction = np.argmax(pred_proba, axis=1)[0]
            probabilities = pred_proba[0]
        
        triage_level = int(prediction) + 1
        triage_labels = {1: 'Mild', 2: 'Moderate', 3: 'Severe'}
        
        recommendations = {
            1: "Self-care at home. Rest and stay hydrated. Monitor symptoms.",
            2: "Consult a healthcare provider within 24-48 hours.",
            3: "Seek immediate medical attention. Contact emergency services."
        }
        
        return {
            'triage_level': triage_level,
            'triage_label': triage_labels[triage_level],
            'confidence': {
                'Mild': float(probabilities[0]),
                'Moderate': float(probabilities[1]),
                'Severe': float(probabilities[2])
            },
            'recommendation': recommendations.get(triage_level, "Consult healthcare provider")
        }
    
    def predict(self, symptoms_text, age=30, gender='Other'):
        """Wrapper that accepts string input"""
        if isinstance(symptoms_text, str):
            if ',' in symptoms_text:
                symptoms_list = [s.strip().lower() for s in symptoms_text.split(',')]
            else:
                symptoms_list = symptoms_text.lower().split()
        elif isinstance(symptoms_text, list):
            symptoms_list = symptoms_text
        else:
            symptoms_list = []
        
        return self.predict_from_symptoms(symptoms_list, age, gender)


# Test the module
if __name__ == "__main__":
    print("="*60)
    print("Testing ML Inference Module")
    print("="*60)
    
    ml = SACATriageModel()
    
    test_cases = [
        (['runny nose', 'sneezing', 'cough'], 25, 'Female'),
        (['fever', 'cough', 'fatigue'], 45, 'Male'),
        (['chest pain', 'shortness of breath'], 65, 'Male'),
    ]
    
    for symptoms, age, gender in test_cases:
        result = ml.predict_from_symptoms(symptoms, age, gender)
        print(f"\\nSymptoms: {symptoms}")
        print(f"  -> Triage: {result['triage_label']}")
        print(f"  -> Confidence: {result['confidence'][result['triage_label']]:.2%}")
    
    print("\\n[OK] Module ready for integration!")
'''
    
    # Save inference module
    with open('../app_integration/saca_ml_inference.py', 'w', encoding='utf-8') as f:
        f.write(inference_code)
    
    print("\n[OK] Created inference module at 'app_integration/saca_ml_inference.py'")
    
    # Copy model files
    import shutil
    files_to_copy = [
        ('../models/preprocessing_objects.pkl', 'preprocessing_objects.pkl'),
        ('../models/best_model_name.txt', 'best_model_name.txt'),
        ('../models/saca_triage_model_rf.pkl', 'saca_triage_model_rf.pkl'),
        ('../models/saca_triage_model_xgb.json', 'saca_triage_model_xgb.json')
    ]
    
    for src, dst in files_to_copy:
        try:
            if os.path.exists(src):
                shutil.copy(src, f'../app_integration/{dst}')
                print(f"   Copied {dst}")
        except Exception as e:
            print(f"   Warning: Could not copy {dst}: {e}")
    
    print("\n[OK] All files ready in 'app_integration/' folder")
    print("\nShare this folder with your friend for integration!")

if __name__ == "__main__":
    create_inference_module()