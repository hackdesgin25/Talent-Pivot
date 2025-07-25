import express, { Request, Response } from "express";
import dotenv from "dotenv";
import cors from "cors";
// Temporarily comment out routes to test
import router from "./v1/routes";

dotenv.config();

const app = express();
app.use(
  cors({
    origin: process.env.CLIENT_URL || "http://localhost:5173",
    credentials: true,
  })
);
app.use(express.json());

app.get("/__health", (_req: Request, res: Response) => {
  res.json({ 
    status: "OK", 
    message: "TalentPivot backend is running.",
    timestamp: new Date().toISOString(),
    port: process.env.PORT || 4000
  });
});

// Simple test endpoint
// app.get("/api/v1/test", (_req, res) => {
//   res.json({ 
//     message: "Backend is working!", 
//     timestamp: new Date().toISOString() 
//   });
// });

// Temporarily comment out problematic routes
app.use("/api/v1", router);

export default app;
