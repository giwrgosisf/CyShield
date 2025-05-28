# This  is the session_handler.py file, which contains the logic for handling Telegram sessions.
# It includes functions for saving credentials, checking if a phone number is registered, sending a code, and logging in.
# This file is used by the main FastAPI application to manage user sessions and authentication with Telegram.
# app/session_handler.py

import os
import json
import asyncio
from telethon import TelegramClient, events


session_lock = asyncio.Lock()


SESSIONS_DIR = "app/sessions"
CREDENTIALS_FILE = "app/credentials/credentials.json"


os.makedirs(SESSIONS_DIR, exist_ok=True)
os.makedirs(os.path.dirname(CREDENTIALS_FILE), exist_ok=True)


# This function saves or updates the credentials.json file with the provided phone number, API ID, and API hash.
async def save_credentials(phone_number, api_id, api_hash):
    """Save or update credentials.json"""
    if os.path.exists(CREDENTIALS_FILE):
        with open(CREDENTIALS_FILE, "r") as f:
            try:
                credentials = json.load(f)
            except Exception:
                credentials = []
    else:
        credentials = []

  
    credentials = [cred for cred in credentials if cred["phone_number"] != phone_number]

    
    credentials.append({
        "phone_number": phone_number,
        "api_id": api_id,
        "api_hash": api_hash
    })

    with open(CREDENTIALS_FILE, "w") as f:
        json.dump(credentials, f, indent=2)

# This function checks if a session file exists for the given phone number.
# If it exists, it means the phone number is already registered.
async def is_registered_phone(phone_number: str) -> bool:
    """Check if the phone number exists in the credentials.json file."""
    if not os.path.exists(CREDENTIALS_FILE):
        return False

    with open(CREDENTIALS_FILE, 'r') as f:
        credentials = json.load(f)

    for entry in credentials:
        if entry.get("phone_number") == phone_number:
            return True
    return False


# This function sends a verification code to the provided phone number using the Telethon library.
# It first checks if the phone number is already registered.
# If it is, it skips sending the code.
# If not, it creates a new TelegramClient instance and sends the code.
async def send_code(api_id, api_hash, phone_number):
    async with session_lock:
        if await is_registered_phone(phone_number):
            print(f"[{phone_number}] Session already exists, skipping send_code.", flush=True)
            return "already_authorized"

        client = TelegramClient(f"{SESSIONS_DIR}/{phone_number}", api_id, api_hash)
        await client.connect()

        result = await client.send_code_request(phone_number)
        await client.disconnect()

        return result.phone_code_hash


# This function logs in to the Telegram account using the provided credentials.
async def safe_login(api_id, api_hash, phone_number, code, phone_code_hash, password=None):
    async with session_lock:
        client = TelegramClient(f"{SESSIONS_DIR}/{phone_number}", api_id, api_hash)
        await client.connect()

        if not await client.is_user_authorized():
            await client.sign_in(phone_number, code=code, phone_code_hash=phone_code_hash)
            if password:
                await client.sign_in(password=password)

        await client.disconnect()

        
        await save_credentials(phone_number, api_id, api_hash)

        print(f"[{phone_number}] Login complete.", flush=True)
