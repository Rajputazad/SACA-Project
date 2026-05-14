from pydantic import BaseModel
from typing import List

class WordEntry(BaseModel):
    word: str
    meaning: List[str]