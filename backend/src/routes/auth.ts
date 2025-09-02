// src/routes/auth.ts

import { Router } from "express";
import {
  register,
  login,
  getMe,
  updateMe,
  getUserById,
} from "../controllers/auth.controller";
import { requireAuth } from "../middleware/auth";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", requireAuth, getMe);

// New: update the authenticated user
router.put("/me", requireAuth, updateMe);
router.get("/users/:id", getUserById); // ← add this route to get user by ID

export default router;
