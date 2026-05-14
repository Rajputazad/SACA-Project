from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from model import predict
from nlp_processing import extract_symptoms, translate_to_english

app = FastAPI(title="SACA NLP API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class TriageRequest(BaseModel):
    text: str
    age: int = 30
    gender: str = "Other"
    language: str = "english"


@app.get("/")
def home():
    return {"message": "SACA NLP API running"}


@app.post("/triage")
def triage(request: TriageRequest):
    if request.language.lower() == "yolngu":
        lang_choice = 2
        processed_text = translate_to_english(request.text)
    else:
        lang_choice = 1
        processed_text = request.text

    symptoms = extract_symptoms(processed_text, lang_choice)

    if not symptoms:
        return {
            "input_text": request.text,
            "processed_text": processed_text,
            "symptoms": [],
            "severity": "Could not determine",
            "confidence": {},
            "recommendation": "Please enter clearer symptoms.",
        }

    severity = predict(processed_text)

    return {
        "input_text": request.text,
        "processed_text": processed_text,
        "symptoms": symptoms,
        "severity": severity,
        "confidence": {},
        "recommendation": "Basic model prediction",
    }