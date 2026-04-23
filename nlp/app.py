from model import train_model, predict
from speech import get_voice_input
from nlp_processing import extract_symptoms, translate_to_english
import json
from langdetect import detect

# -----------------------------
# Load JSON file with words/meanings
# -----------------------------
with open("symptoms.json", "r", encoding="utf-8") as file:
    words_db = json.load(file)

# -----------------------------
# Language detection function
# -----------------------------
def detect_language(text):
    try:
        lang = detect(text)
        if lang == 'en':
            return "english"
        else:
            return "yolngu"
    except:
        return "yolngu"

# -----------------------------
# Get meanings based on user input & language
# -----------------------------
def get_meanings(user_input, lang_choice=None):
    user_input = user_input.lower()
    
    # Determine language
    if lang_choice == 1:
        lang = "english"
    elif lang_choice == 2:
        lang = "yolngu"
    else:
        lang = detect_language(user_input)
    
    results = []
    
    for entry in words_db:
        word_lower = entry["word"].lower()
        meaning = entry["meaning"]
        
        if word_lower in user_input:
            if lang == "english" and all(ord(c) < 128 for c in word_lower):
                results.append(f"{entry['word']}: {meaning}")
            elif lang == "yolngu" and any(ord(c) > 127 for c in word_lower):
                results.append(f"{entry['word']}: {meaning}")
    
    if not results:
        return "No matching words found." if lang == "english" else "Djäma nhäma nhakunŋur ga dhäwu."
    
    return "\n".join(results)

# -----------------------------
# Menu
# -----------------------------
def menu():
    print("\nSACA AI TRIAGE SYSTEM")
    print("1. Train Model")
    print("2. Enter Symptoms (Text)")
    print("3. Enter Symptoms (Voice)")
    print("4. Exit")

# -----------------------------
# Main Loop
# -----------------------------
while True:
    menu()
    choice = input("Select option: ")

    if choice == "1":
        train_model()

    elif choice == "2":
        print("\nSelect input language or detection method:")
        print("1 - English input")
        print("2 - Yolngu input")
        print("3 - Automatic detection")
        while True:
            try:
                lang_choice = int(input("Enter 1, 2, or 3: "))
                if lang_choice in [1,2,3]:
                    break
                else:
                    print("Please enter 1, 2, or 3 only.")
            except ValueError:
                print("Invalid input. Enter a number (1, 2, or 3).")
        
        text = input("Enter symptoms: ")
        # Only translate if input is English
        if lang_choice == 1:
          text = translate_to_english(text)

        symptoms = extract_symptoms(text, lang_choice)
        severity = predict(text)
        meanings = get_meanings(text, lang_choice)

        print("Symptoms:", symptoms)
        print("Severity:", severity)
        print("Meanings:\n", meanings)

    elif choice == "3":
        text = get_voice_input()
        if text:
            print("\nSelect input language or detection method:")
            print("1 - English input")
            print("2 - Yolngu input")
            print("3 - Automatic detection")
            while True:
                try:
                    lang_choice = int(input("Enter 1, 2, or 3: "))
                    if lang_choice in [1,2,3]:
                        break
                    else:
                        print("Please enter 1, 2, or 3 only.")
                except ValueError:
                    print("Invalid input. Enter a number (1, 2, or 3).")
            
            if lang_choice == 1 or (lang_choice == 3 and detect_language(text) == "english"):
                text = translate_to_english(text)
            
            symptoms = extract_symptoms(text, lang_choice)
            severity = predict(text)
            meanings = get_meanings(text, lang_choice)

            print("Symptoms:", symptoms)
            print("Severity:", severity)
            print("Meanings:\n", meanings)

    elif choice == "4":
        break

    else:
        print("Invalid choice")