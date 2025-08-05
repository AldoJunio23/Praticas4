var admin = require("firebase-admin");

var serviceAccount = require("./cantinhodoespeto-5c8e3-firebase-adminsdk-g8kmn-4d5e9146e0.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

module.exports = { db };
