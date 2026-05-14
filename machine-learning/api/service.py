import json
from typing import List, Optional
from models import WordEntry

class DictionaryService:
    def __init__(self, json_file: str):
        # Load JSON 
        with open(json_file, encoding="utf-8") as f:
            data = json.load(f)

        # Normalize lowercase and remove duplict.
        self.words_index = {}
        for entry in data:
            key = entry['word'].lower()
            if key not in self.words_index:
                self.words_index[key] = entry
            else:
                # Merge meanings if duplicate
                existing_meanings = set(self.words_index[key]['meaning'])
                new_meanings = set(entry['meaning'])
                self.words_index[key]['meaning'] = list(existing_meanings.union(new_meanings))

        # pagination sorted word
        self.sorted_words = sorted(self.words_index.values(), key=lambda x: x['word'].lower())

    def get_all_words(self, page: int = 1, limit: int = 50) -> List[WordEntry]:
        start = (page - 1) * limit
        end = start + limit
        return self.sorted_words[start:end]

    def get_word(self, word: str) -> Optional[WordEntry]:
        return self.words_index.get(word.lower())

    def search(self, query: str, page: int = 1, limit: int = 50) -> List[WordEntry]:
        query_lower = query.lower()
        filtered = [
            entry for entry in self.sorted_words
            if query_lower in entry['word'].lower() or
               any(query_lower in m.lower() for m in entry['meaning'])
        ]
        start = (page - 1) * limit
        end = start + limit
        return filtered[start:end]