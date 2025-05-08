import WebSocket from 'ws';
import { getAllUsers } from './db.js';

const SIGNAL_API = 'ws://signal-api:8080';

// WebSocket is a protocol that provides full-duplex communication channels
// over a single TCP connection. It is commonly used in real-time web applications
// to enable interactive communication between a client and a server.
// We map the user's phone number to their WebSocket connection
// to manage multiple connections efficiently.
const activeSockets = new Map();

// The startWebSocketListeners function initializes WebSocket connections
// for all users in the database. It retrieves the list of users
// and establishes a connection for each user. The connections are stored
// in the activeSockets map, allowing for easy management and access.
async function startWebSocketListeners() {
  const users = await getAllUsers();
  users.forEach(connectUser);
}
// The connectUser function establishes a WebSocket connection
// for a specific user. It checks if the user is already connected
// and if not, creates a new WebSocket connection. The function
// also sets up event listeners for the WebSocket connection,
// including handling incoming messages, errors, and connection closures.
// The function uses the user's phone number to create the WebSocket URL
function connectUser(user) {
  if (activeSockets.has(user.phone)) {
    console.warn(`Already connected to ${user.phone}`);
    return;
  }

  const socket = new WebSocket(`${SIGNAL_API}/v1/receive/${user.phone}`);
  activeSockets.set(user.phone, socket);


  socket.on('open', () => {
    console.log(`Listening for messages on ${user.phone}`);
  });

  socket.on('message', handleMessage(user));

  socket.on('error', err => {
    console.error(`WebSocket error for ${user.phone}:`, err.message);
  });

  socket.on('close', () => {
    console.warn(`Connection closed for ${user.phone}. Reconnecting in 5s...`);
    setTimeout(() => connectUser(user), 5000);
  });
}

// The handleMessage function processes incoming messages
// from the WebSocket connection. It parses the message data
// and extracts relevant information such as the sender, receiver,
// message body, and timestamp. The function then logs the message
// details to the console, indicating whether it is an incoming
// or outgoing message. The function also handles errors
// that may occur during message processing.
function handleMessage(user) {
  return data => {
    try {
      const { envelope: env } = JSON.parse(data);
      const senderName = env.sourceName || env.source || '[Unknown Sender]';
      const receiverName = env.source === user.phone
        ? env.dataMessage?.destinationName
          || env.syncMessage?.sentMessage?.destinationName
          || env.dataMessage?.destination
          || env.syncMessage?.sentMessage?.destination
          || '[Unknown Receiver]'
        : user.name || user.phone;
      const body = env.dataMessage?.message || env.syncMessage?.sentMessage?.message;
      if (!body) return;
      const timestamp = new Date(env.timestamp).toLocaleString();
      console.log(
        env.source === user.phone
          ? `[OUTGOING] ${senderName} -> ${receiverName} at ${timestamp}: ${body}`
          : `[INCOMING] ${receiverName} <- ${senderName} at ${timestamp}: ${body}`
      );
    } catch (err) {
      console.error(`Failed to process message for ${user.phone}:`, err.message);
    }
  };
}

export { startWebSocketListeners, connectUser };
