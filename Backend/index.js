import dotenv from "dotenv";
dotenv.config();
import express from "express";
import cors from "cors";


import userRouter from "./src/Modules/User/user.controller.js";
import authRouter from "./src/Modules/Auth/auth.controller.js";
import messageRouter from "./src/Modules/message/message.controller.js";

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(cors());

// Mount the module routes
app.use("/user", userRouter);
app.use("/auth", authRouter);
app.use("/message", messageRouter);

app.all("*", (req, res) => {
  res.status(404).send("Not Found");
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
