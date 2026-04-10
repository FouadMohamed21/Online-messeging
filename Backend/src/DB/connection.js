import mysql2 from "mysql2";
const db = mysql2.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "messege_system",
});
db.connect((err) => {
  if (err) return console.log(err ,"Failed to connect to database");
  console.log("Connected successfully to database");
});
export default db;
