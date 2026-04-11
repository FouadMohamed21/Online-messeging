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

export const getConversations = (req, res) => {
  const { userId } = req.params;
  const query = `
    SELECT u.id, u.name, u.email,
           MAX(m.id) AS lastMessageId,
           (SELECT content FROM messages WHERE id = MAX(m.id)) AS lastMessage,
           (SELECT created_at FROM messages WHERE id = MAX(m.id)) AS lastMessageAt
    FROM messages m
    JOIN users u ON u.id = CASE
      WHEN m.senderId = ? THEN m.receiverId
      ELSE m.senderId
    END
    WHERE m.senderId = ? OR m.receiverId = ?
    GROUP BY u.id, u.name, u.email
    ORDER BY lastMessageId DESC
  `;
  db.query(query, [userId, userId, userId], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    return res.status(200).json({ contacts: results });
  });
};
