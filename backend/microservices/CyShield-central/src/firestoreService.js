const { timeStamp } = require('console');
const path = require('path');
const admin = require('./firebaseAdmin');

const db = admin.firestore();

async function saveToxicMessage(userId, content) {
  await db.collection('toxic_messages').add({
    user_id: userId,
    content: content,
    timestamp: new Date()
  });
}


async function logNotification(userId, { type, body, metadata = {} }) {
  const notificationRef = db
    .collection('users')
    .doc('8Ih04XZWFccmtDSajCqXbRh16tn2')
    .collection('notifications')
    .doc();
  await notificationRef.set({
    type,
    body,
    seen: false,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    ...metadata
  });
}


module.exports = { 
  saveToxicMessage,
  logNotification
};
