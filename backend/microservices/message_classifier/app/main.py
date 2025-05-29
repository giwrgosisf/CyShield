from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Item(BaseModel):
    text: str

@app.post("/classify")
async def classify_text(item: Item):
    text_to_classify = item.text.lower()
    
    
    label = "non-toxic"
    
    
    if "toxic" in text_to_classify:
        label = "toxic"
    
    # Return label in the expected format
    return {"label": label}