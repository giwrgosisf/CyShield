const admin = require('firebase-admin');
const path = require('path');
const serviceAccount = require(
    path.resolve(__dirname, '../serviceAccountKey/cyshield-guardians-app-firebase-adminsdk-fbsvc-decf01a983.json')
  );

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id
  });
}

module.exports = admin;