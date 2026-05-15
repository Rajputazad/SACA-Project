from pydantic import BaseModel, Field
from typing import Dict, List, Optional


class TriageRequest(BaseModel):
    text: str = Field(..., min_length=1, description="Symptoms in English or Yolngu")
    language: str = Field("auto", description="english, yolngu, or auto")


class PossibleCondition(BaseModel):
    condition: str
    match_score: float
    matched_symptoms: List[str]
    common_symptoms: List[str]
    note: str


class TriageResponse(BaseModel):
    input_text: str
    detected_language: str
    processed_text: str
    input_symptoms: List[str]
    predicted_severity: str
    triage_level: Optional[int] = None
    confidence: Dict[str, float]
    possible_conditions: List[PossibleCondition]
    suggestion: str
    important_details: List[str]
    model_used: str
