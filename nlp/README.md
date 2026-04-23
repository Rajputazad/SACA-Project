# Indigenous-Triage-model

An AI-based triage system that allows users to input symptoms via **text or voice** in **English or Yolngu languages**. The system processes input using basic NLP techniques, removes irrelevant words, extracts key symptoms, and predicts severity using a trained model. It supports language selection and ensures outputs remain in the user’s chosen language.

---

## 📂 Folder Structure

```
saca_project/
│
├── app.py
├── nlp_processing.py
├── model.py
├── speech.py
├── requirements.txt
│
├── data/
│   └── symptoms.csv
│
└── model/
```

---

## 🏗️ Model Architecture

```
                   +----------------------+
                   |      app.py          |
                   |  (Main Menu & Loop)  |
                   +----------------------+
                              |
          ------------------------------------------------
          |                                              |
+----------------------+                     +-----------------------+
|   Model Module       |                     | NLP Processing Module |
|  model.py            |                     | nlp_processing.py     |
| - train_model()      |                     | - preprocess_text()   |
| - predict(text)      |                     | - extract_symptoms()  |
+----------------------+                     | - translate_to_english() |
                                              +-----------------------+
                              |
                              v
                   (User Input: text / voice)
```

---

## ⚙️ How to Run

Navigate to your project folder:

```
C:\Users\john\Downloads\saca_project>
```

### Step 1: Install dependencies

```
pip install -r requirements.txt
```

### Step 2: Run the application

```
python app.py
```

---

## 🖥️ Expected Output

```
Select input language:
1 - English
2 - Yolngu
3 - Automatic detection
Enter 1, 2, or 3:
```

After selecting language:

```
SACA AI TRIAGE SYSTEM
1. Train Model
2. Enter Symptoms (Text)
3. Enter Symptoms (Voice)
4. Exit
5. Change Language
Select option:
```

### Example Run

```
SACA AI TRIAGE SYSTEM
1. Train Model
2. Enter Symptoms (Text)
3. Enter Symptoms (Voice)
4. Exit
5. Change Language
Select option: 3

Speak your symptoms...
You said: I have headache pain and stomach pain as well

Symptoms: ['headache', 'pain']
Severity: moderate
```

---

## 🚀 Features

* Supports **English and Yolngu languages**
* Accepts **text and voice input**
* Removes **stopwords** (a, an, the, etc.)
* Extracts **key symptoms using NLP**
* Predicts **severity using AI model**
* Allows **dynamic language switching**

---

## 🧠 Future Improvements

* Advanced NLP for better symptom detection
* Improved Yolngu language processing
* Enhanced machine learning model accuracy
* Web or mobile interface

---


