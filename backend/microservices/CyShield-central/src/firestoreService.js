const { timeStamp } = require('console');
const path = require('path');
const admin = require('./firebaseAdmin');

const db = admin.firestore();


 async function findKidByPhoneNumber(phoneNumber) {
  const usersSnapshot = await db.collection('kids')
    .where('phone_number', '==', phoneNumber)
    .get();

  if (usersSnapshot.empty) {
    return null;
  }
  const userDoc = usersSnapshot.docs[0];
  return  userDoc.id;
 }
  


async function findCoreSpondingParents(kiId) {
  const kidDoc = await db.collection('kids').doc(kiId).get();
  const parents = kidDoc.data().parents || [];
  if (!parents || parents.length === 0) {
    return [];
  }
  return parents;
}

async function logNotification(userId, { type, body, metadata = {} }) {
  const notificationRef = db
    .collection('users')
    .doc(userId)
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

async function saveToxicMessage(user_id, text) {
  const toxicMessageRef = db.collection('kids').doc(user_id).collection('flaggedmessages').doc();
  await toxicMessageRef.set({
    text,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });
  
}


module.exports = { 
  saveToxicMessage,
  logNotification,
  findKidByPhoneNumber,
  findCoreSpondingParents,
  saveToxicMessage
};
