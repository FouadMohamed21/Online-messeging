import db from "../../DB/connection.js";

export const sendMessage = (req, res) => {
  const { senderId, receiverId, content } = req.body;
  const query = "INSERT INTO messages (senderId, receiverId, content) VALUES (?, ?, ?)";
  db.query(query, [senderId, receiverId, content], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    return res.status(201).json({ message: "Message sent", id: results.insertId });
  });
};

export const getMessages = (req, res) => {
  const { user1, user2 } = req.params;
  const query = "SELECT * FROM messages WHERE (senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?) ORDER BY id ASC";
  db.query(query, [user1, user2, user2, user1], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    return res.status(200).json({ messages: results });
  });
};
