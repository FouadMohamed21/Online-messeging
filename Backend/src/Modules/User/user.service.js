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
