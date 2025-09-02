import admin from "firebase-admin";
import serviceAccount from "../utils/service-account.json";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export default admin;
