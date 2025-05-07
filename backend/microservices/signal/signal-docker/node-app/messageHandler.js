const axios = require('axios');
const db = require('./db');
// For every user in the database, we will poll the Signal API for new messages
// and log them to the console. The polling interval is set to 5 seconds by default.
// The function will check for new messages and log them to the console.
async function pollMessages() {
  const users = await db.getAllUsers();
  const SIGNAL_API = 'http://signal-api:8080';

  for (const user of users) {
    try {
      // Api call to get messages for the user
      // The API returns an array of messages, each containing an envelope with the message details
      // The envelope contains the source and destination of the message, as well as the message body
      // The API also returns the timestamp of the message, which is used to format the output
      // The API call is made using axios, which is a promise-based HTTP client for the browser and Node.js
      const res = await axios.get(
        `${SIGNAL_API}/v1/receive/${user.phone}`,
        { timeout: 30000 }
      );

      if (Array.isArray(res.data) && res.data.length > 0) {
        

        res.data.forEach(msg => {
          const env = msg.envelope;
        
          
          const senderName = env.sourceName || env.source || '[Unknown Sender]';
        
          
          let receiverName;
          if (env.source === user.phone) {
            
            receiverName = env.dataMessage?.destinationName ||
                           env.syncMessage?.sentMessage?.destinationName ||
                           env.dataMessage?.destination ||
                           env.syncMessage?.sentMessage?.destination ||
                           '[Unknown Receiver]';
          } else {
            
            receiverName = user.name || user.phone || '[Unknown Receiver]';
          }
        
          
          const body = env.dataMessage?.message || 
               env.syncMessage?.sentMessage?.message || 
               null;

           if (!body) return;
        
          
          const timestamp = new Date(env.timestamp).toLocaleString();
        
          
          if (env.source === user.phone) {
            console.log(`[OUTGOING] ${senderName} -> ${receiverName} at ${timestamp}: ${body}`);
          } else {
            console.log(`[INCOMING] ${receiverName} <- ${senderName} at ${timestamp}: ${body}`);
          }
        });
        
   
      }

    } catch (err) {
      if (err.code !== 'ECONNABORTED') {
        console.error(`Polling error for ${user.phone}:`, err.response?.data || err.message);
      }
    }
  }
}
// This function is called to start the polling process.
// It sets an interval to call the pollMessages function every 5 seconds.
// The interval can be changed by passing a different value to the startPolling function.
// The function logs a message to the console indicating that the polling has started.
module.exports = {
  startPolling(interval = 5000) {
    console.log(` Starting message polling every ${interval}ms...`);
    setInterval(pollMessages, interval);
  }
};
