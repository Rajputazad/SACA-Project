SACA ML + Yolngu NLP API

This project is a Python FastAPI REST API for:
- Predicting triage severity from free-text symptoms in English or Yolngu

Project Structure
yolnguAPI/
│
├─ main.py             # FastAPI entry point
├─ models.py           # Pydantic models
├─ requirements.txt    # Python dependencies
└─ venv/               # Python virtual environment

Prerequisites
Python 3.10+ installed
Git (optional, if cloning repo)
Basic knowledge of terminal/command line
Step 1: Clone or download the project
git clone <your-repo-url>
cd yolnguAPI

Or just copy the folder to your local machine.

Step 2: Create a virtual environment

Windows:

python -m venv venv


Windows PowerShell (temporary execution policy fix if needed):

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\venv\Scripts\Activate.ps1

Windows CMD:

venv\Scripts\activate.bat


After activation, your terminal prompt should show (venv).

for exmaple, 

    (venv) PS D:\Folder of things\Codes\yolnguAPI> pip install requirements.txt 

this code is for next step but now terminal should now show (venv)

Step 4: Install dependencies

pip install -r requirements.txt

This installs:

FastAPI
Uvicorn
Pydantic


Step 6: Run the API from the machine-learning folder
python -m uvicorn api.main:app --reload

**  --reload allows the server to restart automatically if you change code


Default URL: http://127.0.0.1:8000


Step 7: Test the API
Swagger UI:
http://127.0.0.1:8000/docs

ReDoc:
http://127.0.0.1:8000/redoc

Endpoints:

/triage : POST Predicts symptom severity from English or Yolngu symptom text

Postman example:

POST http://127.0.0.1:8000/triage
Headers:
Content-Type: application/json

Body:
{
  "text": "I have fever, cough and headache",
  "language": "english"
}

Yolngu-style example:
{
  "text": "rathala' dhurrur'yun muryun",
  "language": "yolngu"
}

Response includes:
- input_symptoms
- predicted_severity
- confidence
- suggestion
- important_details


Notes:

## Always activate the virtual environment before running commands

## Use /docs to test API during development
## Yolngu dictionary data from the NLP zip is integrated at nlp/resources/yolngu_dictionary.json
