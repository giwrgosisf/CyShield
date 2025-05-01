#This is the main entry point for the FastAPI application.
# it initializes the FastAPI app and defines the API endpoints for sending codes and logging in.
#The endpoints are designed to handle requests for sending verification codes and logging in to Telegram using the Telethon library.

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncio
from app.session_handler import send_code, safe_login

app = FastAPI()

class SendCodeRequest(BaseModel):
    phone_number: str
    api_id: int
    api_hash: str

class LoginRequest(BaseModel):
    phone_number: str
    api_id: int
    api_hash: str
    code: str
    phone_code_hash: str
    password: str = None

@app.post("/send-code")
async def send_code_route(request: SendCodeRequest):
    try:
        result = await send_code(request.api_id, request.api_hash, request.phone_number)
        if result == "already_authorized":
            return {"status": "already_authorized"}
        return {"status": "code_sent", "phone_code_hash": result}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/login")
async def login_route(request: LoginRequest):
    try:
        client = await safe_login(
            request.api_id,
            request.api_hash,
            request.phone_number,
            request.code,
            request.phone_code_hash,
            request.password
        )
        return {"status": "success", "message": "Logged in and listening!"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
