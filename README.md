

<h1>CyShield</h1>

<p align="center">
  <img src="guardians_app/assets/cyshield_logo.png" alt="CyShield Logo" height="200"/>
</p>

CyShield is a  real time cyberbullying detection platform designed to empower parents and guardians to take timely action when their child is at risk of being bullied online. This project is composed of several microservices, each responsible for a specific part of the CyShield platform. The architecture is designed for scalability, modularity, and ease of maintenance. In order to access the following services remotely, you must use a domain. This project was tested under the CyShield.org domain, and service mapping has been configured at that address using Cloudflare's secure tunneling and SSL/TLS encryption.

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
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge)




| Layer             | Technologies Used                                     |
|-------------------|-------------------------------------------------------|
| Backend           | Node.js, Python, Docker, Redis                        |
| Frontend          | Flutter, Bloc                                         |
| Storage           | Firestore, SQLite                                     |
| Authentication    | Firebase Authentication                               |
| Notifications     | Firebase Cloud Messaging (FCM)                        |
| Messaging APIS    | Telethon, Signal-CLI                                  |




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



### 2. Message Classifier
- **Location:** `microservices/message_classifier/`
- **Role:** Containerized inference service for the Greek BERT model.
- **Key Technologies:** Python, FastAPI, PyTorch.
- **Responsibilities:**
  - Exposes an HTTP API for message classification.
  - Runs the inference pipeline in a Docker container.
  

### 3. Signal
- **Location:** `microservices/signal/signal-docker/`
- **Role:** Handles Signal messaging integration.
- **Key Technologies:** Node.js, WebSockets, Express.
- **Responsibilities:**
  - Manages Signal device linking and message relay.
  - Listens for incoming Signal messages and forwards them to the central service.

### 4. Telegram
- **Location:** `microservices/telegram/telethon-docker/`
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


## Frontend Applications

CyShield features two main frontend applications, each serving a distinct user group and purpose:

### 1. Guardians App
- **Purpose:**  
  Designed for parents and guardians, this app allows them to monitor their child's online interactions, receive real-time alerts about potential cyberbullying incidents, and manage notification preferences. Parents can view only toxic messages that threir kid recives or sents not entire converstios respecting chlids privacy
- **Structure:**  
  Cross-platform mobile application.
- **Technologies:**  
  - **Flutter (Dart):** For cross-platform mobile development  
  - **Bloc:** For state management and separation of UI from business logic 
  - **Firebase Authentication:** For secure login 
 - **Firestore Database:** For retrieving essential user and notification data  
  - **Firebase Cloud Messaging (FCM):** For real-time notifications

### 2. Kids App
 - **Purpose:**  
  Installed on the child's device, this app connects the child's messaging applications with the backend, enabling real-time monitoring of messages. It facilitates the backend's ability to listen for and analyze messages as they are sent or received, ensuring timely detection of potential cyberbullying incidents.
- **Structure:**  
  Cross-platform mobile application.
- **Technologies:** 
  - **Bloc:** For state management and separation of UI from
  - **Flutter (Dart):** For cross-platform mobile development  
  - **Firebase Authentication:** For secure login  
  - **Background Services Connection:** For credentials collection and linking messaging accounts to the backend  
  - **Secure Communication:** Ensures all data sent to the backend is encrypted and privacy-respecting

## Example Workflow

To better understand how CyShield operates in practice, you can watch an **[example workflow video here]**(https://vimeo.com/1090210748/40bcac9a28?share=copy).

**Scenario Overview:**  
1. **Child App Setup:**  
   The child installs the Kids App, pairs with a guardian and links their telegram account to the CyShield backend.

2. **Guardian App Setup:**  
   The parent or guardian installs the Guardians App and connects to their account and motitors toxic activity.

3. **Message Flow:**  
   - The child receives three messages from telegram: two containing cyberbullying content and one normal message.
   - The backend detects in real-time the two cyberbullying messages.
   - The parent receives real-time alerts for the toxic messages via the Guardians App, while the normal message is not flagged.





---






## Notes

- Ensure your Firebase service account key is placed in the correct location as referenced in `CyShield-central`.
- For development, you may run individual services using `npm start` or `python ...` as appropriate.
- The ML service requires a GPU for optimal performance.
- **Notice:**  
The Signal CLI and Telethon libraries used for messaging integration are not official APIs; they are used for learning purposes only!
  - [Signal CLI GitHub Repository](https://github.com/AsamK/signal-cli)
  - [Telethon GitHub Repository](https://github.com/LonamiWebs/Telethon)

## Contributors

- **Christos Stamoulos**  
  [GitHub Profile](https://github.com/ChristosStamoulos)  
  

- **Dejvid Isufaj**  
  [GitHub Profile](https://github.com/giwrgosisf)  
  
