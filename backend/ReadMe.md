# CyShield Backend

This backend is composed of several microservices, each responsible for a specific part of the CyShield platform. The architecture is designed for scalability, modularity, and ease of maintenance. In order to access the following services remotely, you must use a domain. This project was tested under the CyShield.org domain, and service mapping has been configured at that address using Cloudflare's secure tunneling and SSL/TLS encryption.

## Tech Stack


![npm](https://img.shields.io/badge/npm-CB3837?logo=npm&logoColor=white&style=for-the-badge)
![Axios](https://img.shields.io/badge/Axios-5A29E4?logo=axios&logoColor=white&style=for-the-badge)
![CUDA](https://img.shields.io/badge/CUDA-76B900?logo=nvidia&logoColor=white&style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=for-the-badge)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white&style=for-the-badge)
![Redis](https://img.shields.io/badge/Redis-DC382D?logo=redis&logoColor=white&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black&style=for-the-badge)
![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?logo=pytorch&logoColor=white&style=for-the-badge)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black&style=for-the-badge)



## Microservices Overview

### 1. CyShield-central
- **Location:** `microservices/CyShield-central/`
- **Role:** Central orchestrator and API gateway. Handles message routing, queue management, and notification delivery.
- **Key Technologies:** Node.js, Express, BullMQ (Redis), Firebase Admin SDK.
- **Responsibilities:**
  - Receives messages from various platforms (Telegram, Signal).
  - Enqueues messages for classification.
  - Interacts with the ML service for cyberbullying detection.
  - Sends notifications to guardians via FCM.
  - Manages user and notification data in Firestore.
- **Parallel Architecture:**  
  The `CyShield-central` container is designed to handle multiple tasks in parallel using BullMQ queues and Node.js worker clustering. Incoming messages are processed asynchronously, allowing classification, notification delivery, and database operations to run concurrently. This ensures high throughput and responsiveness, even under heavy load.



### 3. Message Classifier
- **Location:** `microservices/message_classifier/`
- **Role:** Containerized inference service for the Greek BERT model.
- **Key Technologies:** Python, FastAPI, PyTorch.
- **Responsibilities:**
  - Exposes an HTTP API for message classification.
  - Runs the inference pipeline in a Docker container.
  - Provides an API for message classification.

### 4. Signal
- **Location:** `microservices/signal/signal-docker/`
- **Role:** Handles Signal messaging integration.
- **Key Technologies:** Node.js, WebSockets, Express.
- **Responsibilities:**
  - Manages Signal device linking and message relay.
  - Listens for incoming Signal messages and forwards them to the central service.

### 5. Telegram
- **Location:** `microservices/telegram/telegram_api/`
- **Role:** Handles Telegram messaging integration.
- **Key Technologies:** Flutter (for UI), FastAPI (backend), Telethon (Python Telegram API).
- **Responsibilities:**
  - Provides a UI for Telegram login and code verification.
  - Relays Telegram messages to the central service.

## Architecture

- **Message Flow:**  
  1. Messages from Telegram and Signal are received by their respective microservices.
  2. Messages are forwarded to `CyShield-central` via HTTP.
  3. `CyShield-central` enqueues messages for classification and interacts with the ML service.
  4. Classification results are processed, and notifications are sent to guardians if necessary.

- **Communication:**  
  - Internal communication uses HTTP and Redis queues.
  - Notifications are sent using Firebase Cloud Messaging (FCM).

- **Data Storage:**  
  - User and notification data are stored in Firestore.
  - Signal device links are stored in a local SQLite database.

## How to Run the Backend

### Prerequisites

- Docker and Docker Compose installed
- Node.js (for development)
- Python 3.8+ (for ML services)
- Redis (for BullMQ queues)
- Firebase service account credentials

### Steps

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-org/CyShield.git
   cd CyShield/backend
   ```

2. **Set up environment variables:**
   - Copy `.env.example` to `.env` in each microservice as needed and fill in the required values (e.g., Firebase credentials, Redis host).

3. **Start all services using Docker Compose:**
   ```sh
   docker-compose up --build
   ```
   This will build and start all microservices, including the ML model, central orchestrator, and messaging integrations.

4. **Accessing Services:**
   - **Central API:** http://localhost:8000/message
   - **Message Classifier API:** http://localhost:9090/predict
   - **Signal Link UI:** http://localhost:3000/link
   - **Telegram API:** http://localhost:7000/send-code
   - **Telegram API:** http://localhost:7000/login

5. **Logs and Debugging:**
   - Use `docker-compose logs -f` to view logs for all services.
   - Each microservice can also be run and debugged individually if needed.

6. **Stopping Services:**
   ```sh
   docker-compose down
   ```

## Notes

- Ensure your Firebase service account key is placed in the correct location as referenced in `CyShield-central`.
- For development, you may run individual services using `npm start` or `python ...` as appropriate.
- The ML service requires a GPU for optimal performance.

---

