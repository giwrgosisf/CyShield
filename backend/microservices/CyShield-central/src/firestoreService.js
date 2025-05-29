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

async function raiseModerateCaounter(userId) {
  const userRef = db.collection('kids').doc(userId);
  const userDoc = await userRef.get();
  
  if (!userDoc.exists) {
    console.error(`User with ID ${userId} does not exist.`);
    return;
  }
  
  const currentCount = userDoc.data().moderate || 0;
  await userRef.update({
    moderate: currentCount + 1,
    
  });
  
}

async function raiseToxicCaounter(userId) {
  const userRef = db.collection('kids').doc(userId);
  const userDoc = await userRef.get();
  
  if (!userDoc.exists) {
    console.error(`User with ID ${userId} does not exist.`);
    return;
  }
  
  const currentCount = userDoc.data().toxic || 0;
  await userRef.update({
    toxic: currentCount + 1,
    
  });
  
}



async function raiseHealthyCaounter(userId) {
  const userRef = db.collection('kids').doc(userId);
  const userDoc = await userRef.get();
  
  if (!userDoc.exists) {
    console.error(`User with ID ${userId} does not exist.`);
    return;
  }
  
  const currentCount = userDoc.data().healthy || 0;
  await userRef.update({
    healthy: currentCount + 1,
    
  });
  
}

async function saveToxicMessage(user_id, text , score , sender) {
  const toxicMessageRef = db.collection('kids').doc(user_id).collection('flaggedmessages').doc();
  await toxicMessageRef.set({
    text,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    score: score, 
    sender: sender
  });
  
}


module.exports = { 
  saveToxicMessage,
  logNotification,
  findKidByPhoneNumber,
  findCoreSpondingParents,
  saveToxicMessage,
  raiseModerateCaounter,
  raiseToxicCaounter,
  raiseHealthyCaounter
};
