// src/models/Event.ts
import mongoose, { Document, Schema } from "mongoose";

// ── GUEST SUB‐SCHEMA ───────────────────────────────────────────────────────────
export interface IGuest {
  _id: mongoose.Types.ObjectId;
  name: string;
  email: string;
  status: "pending" | "yes" | "no";
}
const GuestSchema = new Schema<IGuest>(
  {
    name: { type: String, required: true },
    email: { type: String, required: true },
    status: {
      type: String,
      enum: ["pending", "yes", "no"],
      default: "pending",
    },
  },
  { _id: true }
);

// ── BUDGET SUB‐SCHEMA ──────────────────────────────────────────────────────────
export interface IBudgetCategory {
  name: string;
  amount: number;
}
const BudgetCategorySchema = new Schema<IBudgetCategory>(
  {
    name: { type: String, required: true },
    amount: { type: Number, required: true },
  },
  { _id: false }
);

export interface IBudget {
  total: number;
  categories: IBudgetCategory[];
}
const BudgetSchema = new Schema<IBudget>(
  {
    total: { type: Number, required: true },
    categories: { type: [BudgetCategorySchema], default: [] },
  },
  { _id: false }
);

// ── LOGISTICS SUB‐SCHEMA ───────────────────────────────────────────────────────
export interface ILogistics {
  location: string;
  scheduleDate: Date;
  scheduleDescription: string;
}
const LogisticsSchema = new Schema<ILogistics>(
  {
    location: { type: String, required: true },
    scheduleDate: { type: Date, required: true },
    scheduleDescription: { type: String, required: true },
  },
  { _id: false }
);

// ── TASKS SUB‐SCHEMA ───────────────────────────────────────────────────────────
export interface ITask {
  id: string;
  name: string;
  category?: string;
  dueDate?: Date;
  notes?: string;
  priority: "low" | "medium" | "high";
  isDone: boolean;
}
const TaskSchema = new Schema<ITask>(
  {
    id: { type: String, required: true },
    name: { type: String, required: true },
    category: String,
    dueDate: Date,
    notes: String,
    priority: {
      type: String,
      enum: ["low", "medium", "high"],
      default: "medium",
    },
    isDone: { type: Boolean, default: false },
  },
  { _id: false }
);

// ── SETTINGS SUB‐SCHEMA ───────────────────────────────────────────────────────
export interface ISettings {
  budget?: IBudget;
  logistics?: ILogistics;
  tasks?: ITask[];
}
const SettingsSchema = new Schema<ISettings>(
  {
    budget: { type: BudgetSchema, default: undefined },
    logistics: { type: LogisticsSchema, default: undefined },
    tasks: { type: [TaskSchema], default: [] },
  },
  { _id: false }
);

// ── MAIN EVENT MODEL ──────────────────────────────────────────────────────────
export interface IEvent extends Document {
  organizer: mongoose.Types.ObjectId;
  title: string;
  date: Date;
  venue: string;
  venueLocation?: {
    type: "Point";
    coordinates: [number, number]; // [lng, lat]
  };
  description?: string;
  guests: IGuest[];
  settings?: ISettings;
  createdAt: Date;
  updatedAt: Date;
}

const EventSchema = new Schema<IEvent>(
  {
    organizer: { type: Schema.Types.ObjectId, ref: "User", required: true },
    title: { type: String, required: true },
    date: { type: Date, required: true },
    venue: { type: String, required: true },
    description: String,
    // Optional GeoJSON Point for venue location
    venueLocation: {
      type: {
        type: String,
        enum: ["Point"],
        required: false,
      },
      coordinates: {
        type: [Number], // [lng, lat]
        required: false,
      },
    },
    guests: { type: [GuestSchema], default: [] },
    settings: { type: SettingsSchema, default: {} },
  },
  { timestamps: true }
);

// Create a sparse 2dsphere index so only docs with coordinates are indexed
EventSchema.index({ venueLocation: "2dsphere" }, { sparse: true });

export default mongoose.model<IEvent>("Event", EventSchema);
