// Minimal working server for Cloud Run
import express, { Request, Response } from "express";
import cors from "cors";
import router from "./v1/routes";
import { testConnection } from "./config/mysql";
import { logConnectionDiagnostics } from "./utils/databaseLogger";

const app = express();
const PORT = parseInt(process.env.PORT || "8080", 10);

// CORS middleware
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json());

// Health check endpoint
app.get("/__health", (req: Request, res: Response) => {
  res.json({
    status: "OK",
    message: "Talent Pivot Health check passed",
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || "development",
    database_configured: !!(process.env.SQL_HOST && process.env.SQL_USER),
  });
});

// Database status endpoint
app.get("/__db-status", async (req: Request, res: Response) => {
  try {
    console.log("🔍 Database status check requested");
    logConnectionDiagnostics();
    await testConnection();

    console.log('✅ Database status check completed successfully');

    res.json({
      status: "OK",
      message: "Database connection successful",
      timestamp: new Date().toISOString(),
      database: {
        host: process.env.SQL_HOST,
        port: process.env.SQL_PORT,
        database: process.env.SQL_DATABASE,
        user: process.env.SQL_USER,
      }
    });
  } catch (error: any) {
    console.error('❌ Database status check failed:', error);
    res.status(500).json({
      status: "ERROR",
      message: "Database connection failed",
      error: error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

app.use("/api/v1", router);

// Start server
const server = app.listen(PORT, () => {
  console.log(`🚀 TalentPivot server running on port ${PORT}`);
  console.log(`Root: http://localhost:${PORT}/`);
  console.log(`Health: http://localhost:${PORT}/__health`);
  console.log(`Test: http://localhost:${PORT}/api/v1/test`);
});

// Handle server startup errors
server.on("error", (error: Error) => {
  console.error("❌ Server failed to start:", error);
  process.exit(1);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("🛑 SIGTERM received, shutting down gracefully");
  server.close(() => {
    console.log("✅ Server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  console.log("🛑 SIGINT received, shutting down gracefully");
  server.close(() => {
    console.log("✅ Server closed");
    process.exit(0);
  });
});
