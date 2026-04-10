import db from "../../DB/connection.js";

export const login = (req, res) => {
  const { email, password } = req.body;
  const query = "SELECT id, name, email FROM users WHERE email = ? AND password = ?";
  db.query(query, [email, password], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (results.length === 0) return res.status(401).json({ message: "Invalid credentials" });
    
    return res.status(200).json({ message: "Login successful", user: results[0] });
  });
};

export const signup = (req, res) => {
  const { name, email, password } = req.body;
  const query = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
  
  db.query(query, [name, email, password], (err, results) => {
    if (err) return res.status(500).json({ message: "Error creating user", error: err });
    return res.status(201).json({ message: "User created successfully", id: results.insertId });
  });
};
