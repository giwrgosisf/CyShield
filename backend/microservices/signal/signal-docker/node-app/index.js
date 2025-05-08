import express, { json, urlencoded, static as serveStatic } from 'express';
import axios from 'axios';
import { addUser } from './db.js';
import { startWebSocketListeners, connectUser } from './messageHandler.js';

const app = express();
app.use(json());
app.use(urlencoded({ extended: true }));
app.use(serveStatic('public'));

const SIGNAL_API = 'http://signal-api:8080';
//Polling is a process that runs in the background to check for new messages
// and handle them accordingly. It is typically used in messaging applications
// to ensure that users receive messages in real-time or near real-time.

// Boot function
// This function is called when the server starts.
// It waits for 10 seconds before starting the WebSocket listeners.
// This delay allows the signal-api to initialize properly.
// The function uses a Promise to create a delay.
// The setTimeout function is used to create the delay.
// The startWebSocketListeners function is called after the delay
async function boot() {
  await new Promise(r => setTimeout(r, 10000));
  startWebSocketListeners();
}

// Link Signal device
// This endpoint generates a QR code link for the user to scan with their Signal app
// and link their device to the server. It uses the Signal API to generate the QR code
// and returns an HTML page with the QR code and a form for the user to enter their phone number.
// The QR code is generated using the device name, which is a unique identifier for the device.
// The user is then prompted to enter their phone number, which is used to identify the device
// and link it to their account. The phone number is stored in the database along with the user ID.
app.get('/link', async (_req, res) => {
  try {
    const uuid = `user-${Date.now()}`;
    const response = await axios.get(`${SIGNAL_API}/v1/qrcodelink?device_name=${uuid}`, {
      headers: { Accept: 'application/json' },
      responseType: 'arraybuffer'
    });

    
    const qrCode = `data:image/png;base64,${Buffer.from(response.data).toString('base64')}`;


  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Link Signal Device</title>
      </head>
      <body style="text-align:center; padding-top:50px;">
        <h2>Scan this QR code with your Signal app</h2>
        <img src="${qrCode}" alt="QR Code" style="border:1px solid black;" />
        <p>Device ID: <code>${uuid}</code></p>

        <form action="/verify" method="post">
          <input type="hidden" name="uuid" value="${uuid}" />
          <label for="phone">Your Signal Phone Number:</label><br/>
          <input type="text" name="phone" id="phone" required placeholder="+3069XXXXXXX"/><br/><br/>
          <button type="submit">Finish Linking</button>
        </form>
      </body>
    </html>
  `);
  } catch (err) {
    console.error('QR link failed:', err.response?.data || err.message);
    res.status(500).send('<h1>Failed to generate QR code</h1>');
  }
});

// Verify Signal device
// This endpoint is called when the user submits the form with their phone number.
// It verifies the device by sending a request to the Signal API with the user ID and phone number.
app.post('/verify', async (req, res) => {
  const { uuid, phone } = req.body;
  if (!uuid || !phone) return res.status(400).send("uuid and phone are required");

  try {
    await addUser(uuid, phone);
    connectUser({ phone, uuid });
    console.log(`Device linked: ${uuid} -> ${phone}`);
    res.send(`
      <html><body style="text-align:center; padding-top:50px;">
        <h2>Success!</h2>
        <p>Device linked and phone saved: <strong>${phone}</strong></p>
        <a href="/link">Link another device</a>
      </body></html>
    `);
  } catch (err) {
    console.error('Verify error:', err.message);
    res.status(500).send("Failed to store user");
  }
});

app.listen(3000, () => {
  console.log("Node app listening on port 3000");
  boot();
});
