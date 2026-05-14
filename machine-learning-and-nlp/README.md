# SACA ML Project - Swin Smart Adaptive Clinical Assistant

## Machine Learning Module for Triage Classification

### Setup Instructions

1. **Create virtual environment:**
```bash
python -m venv venv
venv\Scripts\activate  # On Windows


To run api: nlp/.venv/bin/python -m uvicorn api.main:app --host 0.0.0.0 --port 8000

ipconfig getifaddr en0