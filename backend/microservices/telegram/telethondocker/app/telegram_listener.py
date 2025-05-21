#This script listens for incoming and outgoing messages from multiple Telegram accounts
# and forwards them to a specified HTTP endpoint. It uses the Telethon library for Telegram API interactions.
#it also handles the loading of credentials from a JSON file and manages multiple sessions.

import os
import json
import asyncio
from telethon import TelegramClient, events
import httpx
from datetime import datetime
from zoneinfo import ZoneInfo 


CREDENTIALS_FILE = os.getenv("CREDENTIALS_FILE", "app/credentials/credentials.json")
SESSIONS_DIR = os.getenv("SESSIONS_DIR", "app/sessions")
TARGET_ENDPOINT = os.getenv("TARGET_ENDPOINT", "http://192.168.1.79:8000/message")
credits_lock = asyncio.Lock()


active_clients = {}

# This function handles incoming and outgoing messages
# and forwards them to a specified HTTP endpoint.
# It extracts relevant information from the message and sender,
# including message ID, date, text, sender ID, username, and phone number.
async def message_handler(event, phone_number: str):
    sender = await event.get_sender()
    chat = await event.get_chat()

    message_id = event.id
    message_date = event.date.isoformat()
    message_text = event.raw_text
    sender_id = sender.id if sender else None
    sender_username = getattr(sender, 'username', None)
    sender_phone = getattr(sender, 'phone', None)
    chat_id = chat.id if chat else None
    chat_title = getattr(chat, 'title', None)
    chat_username = getattr(chat, 'username', None)

    sender_name = getattr(sender, 'first_name', None) or getattr(sender, 'title', 'Unknown')
    receiver_name = getattr(chat, 'title', None) or getattr(chat, 'first_name', 'Unknown')
    
    print("================ MESSAGE RECEIVED ================")
    print(f"From Phone: {phone_number}")
    print(f"Time      : {message_date}")
    print(f"Sender    : ID={sender_id}, Username={sender_name}, Phone={sender_phone}")
    print(f"Receiver  : Chat ID={chat_id}, Title={chat_title}, Username={receiver_name}")
    print(f"Message   : {message_text}")
    print("==================================================")

    # Construct the payload to be sent to the target endpoint
    # For now, we are just printing the payload.
    # In the future, we will send this payload to the target endpoint.
    payload = {
        "user_id": phone_number,
        "message": {
            "date": datetime.fromisoformat(message_date).astimezone(ZoneInfo('Europe/Athens')).strftime('%B %d, %Y at %I:%M %p'),
            "text": message_text,
            "platform": "Telegram",
            "from": {  
                "username": sender_name,
            },
            "to": {
                "username": receiver_name,
            }
        }
    }
#   HTTP POST request to the target endpoint
#   This part will be used when we determine the target endpoint and how the rest of the system will work.
#   for now, it's commented out to avoid sending requests to an undefined endpoint.

    # Non-blocking HTTP POST
    async with httpx.AsyncClient() as http:
     try:
        await http.post(TARGET_ENDPOINT, json=payload)
     except Exception as e:
        print(f"Error forwarding message for {phone_number}: {e}")


# Actively monitor messages for a single client
async def monitor_client(client: TelegramClient, phone: str):
    @client.on(events.NewMessage(incoming=True, outgoing=True))
    async def internal_handler(event):
        await message_handler(event, phone)
    print(f"Monitoring messages for {phone}")

# Initializes and starts clients for all credentials
async def start_all_listeners():
    os.makedirs(SESSIONS_DIR, exist_ok=True)
    
    while not os.path.exists(CREDENTIALS_FILE):
        print(f"Waiting for {CREDENTIALS_FILE} to be created...")
        await asyncio.sleep(1)

    async with credits_lock:
        try:
            with open(CREDENTIALS_FILE, 'r') as f:
                credentials = json.load(f)
        except Exception as e:
            raise RuntimeError(f"Failed to load credentials: {e}")

    for entry in credentials:
        phone = entry.get("phone_number")
        api_id = entry.get("api_id")
        api_hash = entry.get("api_hash")

        if not (phone and api_id and api_hash):
            print(f"Skipping invalid credential entry: {entry}")
            continue

        session_path = os.path.join(SESSIONS_DIR, phone)
        client = TelegramClient(session_path, api_id, api_hash)

        await client.start()
    
        await monitor_client(client, phone)

        active_clients[phone] = client
        print(f"Started listener for {phone}")




# This function continuously checks for new clients in the credentials file
# and starts a new listener for each new client.
# It uses a polling interval to check for changes in the credentials file.
async def watch_for_new_clients(poll_interval: float = 5.0):
    print("Started background task to watch for new clients.")
    known_phones = set(active_clients.keys())

    while True:
        await asyncio.sleep(poll_interval)

        async with credits_lock:
            try:
                with open(CREDENTIALS_FILE, 'r') as f:
                    credentials = json.load(f)
            except Exception as e:
                print(f"Error reading credentials while watching: {e}")
                continue

        for entry in credentials:
            phone = entry.get("phone_number")
            api_id = entry.get("api_id")
            api_hash = entry.get("api_hash")

            if phone in known_phones or not (phone and api_id and api_hash):
                continue

            print(f"New client detected: {phone}. Registering...")
            session_path = os.path.join(SESSIONS_DIR, phone)
            client = TelegramClient(session_path, api_id, api_hash)

            try:
                await client.start()
                await monitor_client(client, phone)
                active_clients[phone] = client
                known_phones.add(phone)
                print(f"Started new client for {phone}")
            except Exception as e:
                print(f"Error starting new client {phone}: {e}")







if __name__ == "__main__":
    import asyncio

    async def main():
        await start_all_listeners()
        asyncio.create_task(watch_for_new_clients())

        
        await asyncio.gather(*(client.run_until_disconnected() for client in active_clients.values()))

    asyncio.run(main())

