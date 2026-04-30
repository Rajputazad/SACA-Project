<<<<<<< HEAD
from model import train_model, predict
from speech import get_voice_input
=======
<<<<<<< HEAD
from fastapi import FastAPI
from pydantic import BaseModel
import sys
import os

# Connect to main project
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
sys.path.append(PROJECT_DIR)

from app_integration.saca_ml_inference import SACATriageModel
>>>>>>> 2edbceb (Added ML + NLP integration)
from nlp_processing import extract_symptoms, translate_to_english
from langdetect import detect

# -----------------------------
# Language detection
# -----------------------------
def detect_language(text):
    try:
        lang = detect(text)
        return "english" if lang == "en" else "yolngu"
    except:
        return "yolngu"

# -----------------------------
# Select Language
# -----------------------------
def select_language():
    print("\nSelect input language:")
    print("1 - English")
    print("2 - Yolngu")
    print("3 - Automatic detection")
    
    while True:
        try:
            choice = int(input("Enter 1, 2, or 3: "))
            if choice in [1, 2, 3]:
                return choice
            else:
                print("Enter 1, 2, or 3 only.")
        except ValueError:
            print("Invalid input.")

# -----------------------------
# Menu
# -----------------------------
def menu():
    print("\nSACA AI TRIAGE SYSTEM")
    print("1. Train Model")
    print("2. Enter Symptoms (Text)")
    print("3. Enter Symptoms (Voice)")
    print("4. Exit")
    print("5. Change Language")

# -----------------------------
# MAIN PROGRAM
# -----------------------------
lang_choice = select_language()

while True:
    menu()
    choice = input("Select option: ")

    # -------------------------
    if choice == "1":
        train_model()

    # -------------------------
    elif choice == "2":
        text = input("Enter symptoms: ")

        # Translate only if English
        if lang_choice == 1:
            text = translate_to_english(text)

        symptoms = extract_symptoms(text, lang_choice)
        severity = predict(text)

        print("Symptoms:", symptoms)
        print("Severity:", severity)

    # -------------------------
    elif choice == "3":
        text = get_voice_input()

        if text:
            if lang_choice == 1:
                text = translate_to_english(text)

            symptoms = extract_symptoms(text, lang_choice)
            severity = predict(text)

            print("Symptoms:", symptoms)
            print("Severity:", severity)

    # -------------------------
    elif choice == "4":
        break

    # -------------------------
    elif choice == "5":
        lang_choice = select_language()
        print("Language updated successfully!")

    # -------------------------
    else:
<<<<<<< HEAD
        print("Invalid choice")
=======
        lang_choice = 1
        processed_text = text

    symptoms = extract_symptoms(processed_text, lang_choice)

    if not symptoms:
        return {
            "input_text": request.text,
            "processed_text": processed_text,
            "symptoms": [],
            "severity": "Could not determine",
            "confidence": {},
            "recommendation": "Please enter clearer symptoms."
        }

    result = ml_model.predict_from_symptoms(
        symptoms_list=symptoms,
        age=request.age,
        gender=request.gender.capitalize()
    )

    return {
        "input_text": request.text,
        "processed_text": processed_text,
        "symptoms": symptoms,
        "severity": result["triage_label"],
        "confidence": result["confidence"],
        "recommendation": result["recommendation"]
    }
=======
from model import train_model, predict
from speech import get_voice_input
from nlp_processing import extract_symptoms, translate_to_english
from langdetect import detect

# -----------------------------
# Language detection
# -----------------------------
def detect_language(text):
    try:
        lang = detect(text)
        return "english" if lang == "en" else "yolngu"
    except:
        return "yolngu"

# -----------------------------
# Select Language
# -----------------------------
def select_language():
    print("\nSelect input language:")
    print("1 - English")
    print("2 - Yolngu")
    print("3 - Automatic detection")
    
    while True:
        try:
            choice = int(input("Enter 1, 2, or 3: "))
            if choice in [1, 2, 3]:
                return choice
            else:
                print("Enter 1, 2, or 3 only.")
        except ValueError:
            print("Invalid input.")

# -----------------------------
# Menu
# -----------------------------
def menu():
    print("\nSACA AI TRIAGE SYSTEM")
    print("1. Train Model")
    print("2. Enter Symptoms (Text)")
    print("3. Enter Symptoms (Voice)")
    print("4. Exit")
    print("5. Change Language")

# -----------------------------
# MAIN PROGRAM
# -----------------------------
lang_choice = select_language()

while True:
    menu()
    choice = input("Select option: ")

    # -------------------------
    if choice == "1":
        train_model()

    # -------------------------
    elif choice == "2":
        text = input("Enter symptoms: ")

        # Translate only if English
        if lang_choice == 1:
            text = translate_to_english(text)

        symptoms = extract_symptoms(text, lang_choice)
        severity = predict(text)

        print("Symptoms:", symptoms)
        print("Severity:", severity)

    # -------------------------
    elif choice == "3":
        text = get_voice_input()

        if text:
            if lang_choice == 1:
                text = translate_to_english(text)

            symptoms = extract_symptoms(text, lang_choice)
            severity = predict(text)

            print("Symptoms:", symptoms)
            print("Severity:", severity)

    # -------------------------
    elif choice == "4":
        break

    # -------------------------
    elif choice == "5":
        lang_choice = select_language()
        print("Language updated successfully!")

    # -------------------------
    else:
        print("Invalid choice")
>>>>>>> 72ee80343629e2f46c34c344a919a1604912dbd0
>>>>>>> 2edbceb (Added ML + NLP integration)
