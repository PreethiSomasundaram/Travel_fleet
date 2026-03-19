const admin = require('firebase-admin');

let initialized = false;

const initializeFcm = () => {
  if (initialized) return;

  const projectId = process.env.FCM_PROJECT_ID;
  const clientEmail = process.env.FCM_CLIENT_EMAIL;
  const privateKey = process.env.FCM_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    return;
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey: privateKey.replace(/\\n/g, '\n'),
    }),
  });

  initialized = true;
};

const sendPushNotification = async ({ token, title, body, data = {} }) => {
  initializeFcm();
  if (!initialized || !token) {
    return { skipped: true };
  }

  await admin.messaging().send({
    token,
    notification: { title, body },
    data,
  });

  return { skipped: false };
};

module.exports = { sendPushNotification };
