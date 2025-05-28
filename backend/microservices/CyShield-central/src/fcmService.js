// fcmService.js
const admin = require('./firebaseAdmin');
const db    = admin.firestore();

async function notifyParent(userId, { title, body, data = {}}) {
  const userRef = db.collection('users').doc(userId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    throw new Error(`User ${userId} not found`);
  }

  const tokens = userDoc.data().fcmTokens || [];
  if (tokens.length === 0) {
    console.log(`No FCM tokens for user ${userId}`);
    return;
  }

  const messages = tokens.map(token => ({
    token,
    notification: { title, body },
    data,
    
    android: {
      priority: 'high',
      notification: { sound: 'default', channelId: 'high_alerts' }
    },
    
    apns: {
      headers: { 'apns-priority': '10', 'apns-push-type': 'alert' },
      payload: {
        aps: {
          alert: { title, body },
          sound: 'default'
        }
      }
    }
  }));

  
  if (messages.length === 0) {
    console.log("No valid messages to send.");
    return;
  }

  const response = await admin.messaging().sendEach(messages);

  
  console.log(` FCM sent to ${userId}: ${response.successCount} success, ${response.failureCount} failed`);

  
  const badTokens = [];
  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      const err = resp.error;
      if (
        err.code === 'messaging/invalid-registration-token' ||
        err.code === 'messaging/registration-token-not-registered'
      ) {
        badTokens.push(tokens[idx]);
      }
    }
  });

  if (badTokens.length > 0) {
    await userRef.update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...badTokens),
    });
    console.log(`Removed invalid tokens for ${userId}:`, badTokens);
  }
}

module.exports = { notifyParent };
