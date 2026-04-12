import { Router } from "express";
import * as userService from "./user.service.js";

const router = Router();

// Define endpoints and call the corresponding service functions
router.get("/search", userService.searchUsers);
router.post("/fcm-token", userService.saveFcmToken);

export default router;
