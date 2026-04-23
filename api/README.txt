Yolngu Dictionary API

This project is a Python FastAPI REST API serving a JSON dictionary of Yolngu words and their meanings.

Project Structure
yolnguAPI/
│
├─ main.py             # FastAPI entry point
├─ models.py           # Pydantic models
├─ service.py          # Dictionary service (loading JSON, search, pagination)
├─ yolngu_dictionary.json  # Dictionary data
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


Step 5: Place the JSON dictionary

*# Make sure yolngu_dictionary.json is in the same folder as main.py.


Step 6: Run the API
uvicorn main:app --reload

**  --reload allows the server to restart automatically if you change code


Default URL: http://127.0.0.1:8000


Step 7: Test the API
Swagger UI:
http://127.0.0.1:8000/docs

ReDoc:
http://127.0.0.1:8000/redoc

Endpoints:

/words	: GET	Returns all words (supports pagination: page, limit)
/words/{word}	: GET	Returns meanings for a specific word
/search?q=term	: GET	Search words and meanings (partial, case-insensitive)


Notes:

## Always activate the virtual environment before running commands

## Use /docs to test API during development
## JSON must be properly formatted; each entry:
{
  "word": "example",
  "meaning": ["definition 1", "definition 2"]
}

## Duplicate words will be merged automatically