// src/middleware/auth.ts
import { Request, Response, NextFunction, RequestHandler } from "express";
import jwt from "jsonwebtoken";
import User, { IUser } from "../models/User";

interface JwtPayload { // شكل البيانات المتوقعة داخل jwt 
  userId: string;
}

export const requireAuth: RequestHandler = (req, res, next) => {
  const authHeader = req.headers.authorization; // <— احصل على هيدر التفويض
  if (!authHeader || !authHeader.startsWith("Bearer ")) { // <— تحقق من وجوده
    res.status(401).json({ message: "Unauthorized" });
    return; // <— just return void, don’t return the res
  }
  const token = authHeader.split(" ")[1]; // <— احصل على التوكن من الهيدر
  jwt.verify(token, process.env.JWT_SECRET!, async (err, payload) => {
    if (
      err ||
      !payload ||
      typeof payload !== "object" ||
      !("userId" in payload) // اذا التوكن صحيح  برجع userId
    ) {
      res.status(401).json({ message: "Unauthorized" }); 
      return; // <— same here
    }
    try {
      const user = await User.findById((payload as JwtPayload).userId); // <— ابحث عن المستخدم في قاعدة البيانات
      if (!user) {
        res.status(401).json({ message: "Unauthorized" });
        return; // <— same here
      }
      req.user = user; // احفظ المستخدم في الطلب
      next();
    } catch {
      res.status(401).json({ message: "Unauthorized" });
    }
  });
};
 // بترجع RequestHandler ليتم استخدامه باي  route
export const requireRole = (
  role: "organizer" | "vendor" | "admin"
): RequestHandler => {
  return (req, res, next) => {
    if (!req.user) { // <— تحقق من وجود المستخدم في الطلب
      res.status(401).json({ message: "Unauthorized" });
      return; // <— void return يتوقف عن التنفيذ
    }
    if (req.user.role !== role) {
      res.status(403).json({ message: "Forbidden" });
      return; // <— void return
    }
    next(); // <— also void
  };
};
