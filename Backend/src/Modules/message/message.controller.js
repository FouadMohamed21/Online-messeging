import { Router } from "express";
import * as messageService from "./message.service.js";

const router = Router();
router.post("/", messageService.sendMessage);
router.get("/conversations/:userId", messageService.getConversations);
router.get("/:user1/:user2", messageService.getMessages);
router.delete("/:id", messageService.deleteMessage);

export default router;

