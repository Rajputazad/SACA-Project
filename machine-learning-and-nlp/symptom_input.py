# symptom_input.py - Simple symptom to triage result
from app_integration.saca_ml_inference import SACATriageModel
import warnings
warnings.filterwarnings('ignore')

# Load model
print("Loading ML model...")
ml = SACATriageModel(model_path='./app_integration/')
print("Ready! (Type 'quit' to exit)\n")

while True:
    # Get symptoms
    symptoms_text = input("Enter your symptoms (comma separated): ")
    
    if symptoms_text.lower() == 'quit':
        print("\nGoodbye! Stay healthy!")
        break
    
    if not symptoms_text.strip():
        print("Please enter symptoms!\n")
        continue
    
    # Process symptoms
    symptoms = [s.strip().lower() for s in symptoms_text.split(',')]
    
    # Get prediction
    result = ml.predict_from_symptoms(symptoms, age=30, gender='Other')
    
    # Show result
    print("\n" + "="*50)
    print(f"📋 Symptoms: {', '.join(symptoms)}")
    print("="*50)
    print(f"🏥 Triage Level: {result['triage_level']} ({result['triage_label']})")
    print(f"\n📊 Confidence:")
    print(f"   Mild:     {result['confidence']['Mild']:.1%}")
    print(f"   Moderate: {result['confidence']['Moderate']:.1%}")
    print(f"   Severe:   {result['confidence']['Severe']:.1%}")
    print(f"\n💊 Recommendation:")
    print(f"   {result['recommendation']}")
    print("="*50 + "\n")