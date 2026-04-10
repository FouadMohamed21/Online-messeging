import { Router } from "express";
import * as messageService from "./message.service.js";

const router = Router();
router.post("/", messageService.sendMessage);
router.get("/:user1/:user2", messageService.getMessages);

export default router;
