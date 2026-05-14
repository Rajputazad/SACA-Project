import speech_recognition as sr

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
<<<<<<< HEAD

>>>>>>> 2edbceb (Added ML + NLP integration)
def get_voice_input():
    recognizer = sr.Recognizer()
    try:
        with sr.Microphone() as source:
<<<<<<< HEAD
            print("Speak your symptoms...")
=======
            print("Speak now...")
            recognizer.adjust_for_ambient_noise(source, duration=1)
=======
>>>>>>> origin/master-ML
def get_voice_input():
    recognizer = sr.Recognizer()
    try:
        with sr.Microphone() as source:
            print("Speak your symptoms...")
<<<<<<< HEAD
=======
>>>>>>> 72ee80343629e2f46c34c344a919a1604912dbd0
>>>>>>> 2edbceb (Added ML + NLP integration)
>>>>>>> origin/master-ML
            audio = recognizer.listen(source)

        text = recognizer.recognize_google(audio)
        print("You said:", text)
        return text
<<<<<<< HEAD
    except Exception as e:
        print("Error:", e)
        return ""
=======
<<<<<<< HEAD
    except Exception as e:
        print("Error:", e)
        return ""
=======
<<<<<<< HEAD

    except Exception as e:
        print("Voice input not available. Please type symptoms instead.")
        return ""
=======
    except Exception as e:
        print("Error:", e)
        return ""
>>>>>>> 72ee80343629e2f46c34c344a919a1604912dbd0
>>>>>>> 2edbceb (Added ML + NLP integration)
>>>>>>> origin/master-ML
