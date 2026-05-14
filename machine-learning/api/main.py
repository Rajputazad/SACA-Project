# READ THE README txt to run it

from fastapi import FastAPI, HTTPException, Query
from typing import List
from models import WordEntry
from service import DictionaryService

app = FastAPI(title="Yolngu Dictionary API")

# Initialize
dict_service = DictionaryService("yolngu_dictionary.json")

@app.get("/words", response_model=List[WordEntry])
def get_words(page: int = Query(1, ge=1), limit: int = Query(50, ge=1, le=500)):
    """
    Return paginated list of all words.
    """
    return dict_service.get_all_words(page, limit)

@app.get("/words/{word}", response_model=WordEntry)
def get_word(word: str):
    """
    Return a specific word and its meanings.
    """
    entry = dict_service.get_word(word)
    if not entry:
        raise HTTPException(status_code=404, detail="Word not found")
    return entry

@app.get("/search", response_model=List[WordEntry])
def search_words(q: str = Query(..., min_length=1), page: int = Query(1, ge=1), limit: int = Query(50, ge=1, le=500)):
    """
    Search words and meanings (case-insensitive, partial match)
    """
    results = dict_service.search(q, page, limit)
    return results