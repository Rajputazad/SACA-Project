from fastapi import FastAPI
try:
    from .models import TriageRequest, TriageResponse
    from .triage_service import TriageService
except ImportError:
    from models import TriageRequest, TriageResponse
    from triage_service import TriageService

app = FastAPI(title="SACA ML + Yolngu NLP API")

triage_service = TriageService()


@app.get("/")
def health_check():
    return {
        "message": "SACA API running",
        "triage_endpoint": "POST /triage",
    }


@app.post("/triage", response_model=TriageResponse)
def triage(request: TriageRequest):
    """
    Accept free-text symptoms in English or Yolngu and return triage severity.
    """
    return triage_service.predict(
        text=request.text,
        language=request.language,
    )
