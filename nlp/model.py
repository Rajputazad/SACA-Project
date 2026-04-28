import pandas as pd
import pickle
import os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from nlp_processing import preprocess_text

MODEL_PATH = "model/triage_model.pkl"
VECTORIZER_PATH = "model/vectorizer.pkl"

def train_model():
    data = pd.read_csv("data/symptoms.csv")
    data['text'] = data['text'].apply(preprocess_text)

    X = data['text']
    y = data['label']

    vectorizer = TfidfVectorizer()
    X_vec = vectorizer.fit_transform(X)

    model = LogisticRegression()
    model.fit(X_vec, y)

    os.makedirs("model", exist_ok=True)

    pickle.dump(model, open(MODEL_PATH, "wb"))
    pickle.dump(vectorizer, open(VECTORIZER_PATH, "wb"))

    print("Model trained!")

def predict(text):
    model = pickle.load(open(MODEL_PATH, "rb"))
    vectorizer = pickle.load(open(VECTORIZER_PATH, "rb"))

    processed = preprocess_text(text)
    vec = vectorizer.transform([processed])

    return model.predict(vec)[0]
