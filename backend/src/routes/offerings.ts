import { Router } from "express";
import { requireAuth } from "../middleware/auth"; // if you only want authenticated users
import { listOfferings } from "../controllers/offeringController";

const router = Router();

// public list of offerings; you can add requireAuth middleware if desired
router.get("/", /* requireAuth, */ listOfferings);

export default router;
