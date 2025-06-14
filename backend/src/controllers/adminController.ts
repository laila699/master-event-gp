import { Request, Response } from "express";
import User from "../models/User";

export const getAllUsers = async (req: Request, res: Response) => {
  try {
    // find every user whose role is not 'admin'
    const users = await User.find({ role: { $ne: "admin" } })
      .select("-passwordHash") // omit sensitive fields
      .lean();
    users.forEach((user: any) => {
      user.id = user._id;
      delete user._id;
      console.log("id", user);
    });

    console.log("id", users);

    res.json(users);
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ message: "Failed to load users." });
  }
};
// Delete a single user (unless they’re an admin)
export const deleteUser = async (req: Request, res: Response): Promise<any> => {
  try {
    const { id } = req.params;
    // Prevent deleting another admin
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }
    if (user.role === "admin") {
      return res.status(403).json({ message: "Cannot delete an admin." });
    }

    await User.findByIdAndDelete(id);
    res.json({ message: "User deleted successfully." });
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ message: "Failed to delete user." });
  }
};
