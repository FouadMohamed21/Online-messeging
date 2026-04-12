import dotenv from "dotenv";
dotenv.config();

import admin from "firebase-admin";

let messaging;

try {
  // FIREBASE_SERVICE_ACCOUNT env var holds the full service-account JSON as a string.
  // On Railway: set this variable in your project's Variables tab.
  // Locally: add it to your .env file (paste the JSON on one line).
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;

  if (!raw) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT env variable is not set");
  }

  const serviceAccount = JSON.parse(raw);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  messaging = admin.messaging();
  console.log("✅ Firebase Admin SDK initialized");
} catch (err) {
  console.error("❌ Firebase Admin SDK failed to initialize:", err.message);
}

export { messaging };
