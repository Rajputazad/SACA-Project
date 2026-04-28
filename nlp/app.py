from fastapi import FastAPI
from pydantic import BaseModel

from model import predict
from nlp_processing import extract_symptoms, translate_to_english

app = FastAPI(title="SACA NLP API")

class SymptomRequest(BaseModel):
    text: str
    language: str = "english"  # english / yolngu

@app.get("/")
def home():
    return {"message": "SACA NLP API running"}

@app.post("/triage")
def triage(request: SymptomRequest):
    text = request.text

    lang_choice = 1 if request.language == "english" else 2

    if request.language == "yolngu":
        text = translate_to_english(text)

    symptoms = extract_symptoms(text, lang_choice)
    severity = predict(text)

    return {
        "input_text": request.text,
        "processed_text": text,
        "symptoms": symptoms,
        "severity": severity
    }