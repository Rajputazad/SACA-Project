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