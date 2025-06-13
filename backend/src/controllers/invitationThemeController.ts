import { Request, Response } from "express";
import InvitationTheme from "../models/InvitationTheme";

// Create a new theme
export const createInvitationTheme = async (
  req: Request,
  res: Response
): Promise<any> => {
  try {
    const { name } = req.body;
    const imageUrl = req.file?.path; // if using multer
    if (!name || !imageUrl) {
      return res.status(400).json({ message: "Name and image are required." });
    }
    const theme = await InvitationTheme.create({ name, imageUrl });
    res.status(201).json(theme);
  } catch (err: any) {
    res.status(500).json({ message: "Failed to create theme." });
  }
};

// List all themes
export const getInvitationThemes = async (
  _req: Request,
  res: Response
): Promise<any> => {
  try {
    const themes = await InvitationTheme.find().lean();
    res.json(themes);
  } catch (err: any) {
    res.status(500).json({ message: "Failed to load themes." });
  }
};

// Update a theme (name and/or image)
export const updateInvitationTheme = async (
  req: Request,
  res: Response
): Promise<any> => {
  try {
    const { id } = req.params;
    const update: any = { name: req.body.name };
    if (req.file?.path) update.imageUrl = req.file.path;
    const theme = await InvitationTheme.findByIdAndUpdate(id, update, {
      new: true,
    });
    if (!theme) return res.status(404).json({ message: "Theme not found." });
    res.json(theme);
  } catch (err: any) {
    res.status(500).json({ message: "Failed to update theme." });
  }
};

// Delete a theme
export const deleteInvitationTheme = async (
  req: Request,
  res: Response
): Promise<any> => {
  try {
    const { id } = req.params;
    const theme = await InvitationTheme.findByIdAndDelete(id);
    if (!theme) return res.status(404).json({ message: "Theme not found." });
    res.json({ message: "Theme deleted." });
  } catch (err: any) {
    res.status(500).json({ message: "Failed to delete theme." });
  }
};
