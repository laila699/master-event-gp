// src/middleware/error.ts
import { Request, Response, NextFunction } from "express";

export function errorHandler(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) {
  console.error(err);
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";
  res.status(statusCode).json({ message });
}
export function notFound(req: Request, res: Response) {
  res.status(404).json({ message: "Not Found" }); // <— هذا يعني أن المورد غير موجود
}
export function methodNotAllowed(req: Request, res: Response) {
  res.status(405).json({ message: "Method Not Allowed" }); // <— يستعمل http غلط
}
export function badRequest(req: Request, res: Response) {
  res.status(400).json({ message: "Bad Request" }); // <— هذا يعني أن البيانات يلي بعتها غير صحيحة
}
export function unauthorized(req: Request, res: Response) {
  res.status(401).json({ message: "Unauthorized" }); // <— هذا يعني أن المستخدم غير مخول
}
export function forbidden(req: Request, res: Response) {
  res.status(403).json({ message: "Forbidden" }); //معه توكن صحيح لكن ما عنده الصلاحية يدخل على المسار.
}
export function internalServerError(req: Request, res: Response) {
  res.status(500).json({ message: "Internal Server Error" }); // <— هذا يعني أن هناك خطأ داخلي في الخادم
}
