import db from "../../DB/connection.js";

export const searchUsers = (req, res) => {
  const { q } = req.query;
  const searchTerm = `%${q || ""}%`;
  const query = "SELECT id, name, email FROM users WHERE name LIKE ? OR email LIKE ?";
  db.query(query, [searchTerm, searchTerm], (err, results) => {
    if (err) {
      return res.status(500).json({ message: "Database query error", error: err });
    }
    return res.status(200).json({ message: "Success", users: results });
  });
};

/// Save or update the FCM token for a user so we can send them push notifications.
export const saveFcmToken = (req, res) => {
  const { userId, fcmToken } = req.body;
  if (!userId || !fcmToken) {
    return res.status(400).json({ message: "userId and fcmToken are required" });
  }
  db.query(
    "UPDATE users SET fcm_token = ? WHERE id = ?",
    [fcmToken, userId],
    (err) => {
      if (err) return res.status(500).json({ message: "Database error", error: err });
      return res.status(200).json({ message: "FCM token saved" });
    }
  );
};
