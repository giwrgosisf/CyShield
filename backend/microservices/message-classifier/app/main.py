# app/main.py
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Item(BaseModel):
    text: str



@app.post("/classify")
async def classify_text(item: Item):
    
    text_to_classify = item.text
    
    if "toxic" in text_to_classify.lower():
        classification = "toxic"
    

    return {"classification": classification}