import bcrypt from "bcrypt";
import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { User } from "../types/user";
import { poolPromise, recreatePool } from "../config/mysql";

// Load JWT secret
const JWT_SECRET = process.env.JWT_SECRET || "your-default-secret";
const JWT_EXPIRES_IN = "7d";

// REGISTER USER
export const registerUser = async (req: Request, res: Response) => {
  try {
    const {
      full_name,
      email,
      phone,
      experience,
      band,
      skill,
      password,
      role,
    } = req.body;

    console.log("Registration attempt for email:", email);

    // Input validation
    if (!full_name || !email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: "Full name, email, password, and role are required.",
      });
    }

    if (!["HR", "candidate"].includes(role)) {
      return res.status(400).json({
        success: false,
        message: "Role must be 'HR' or 'candidate'.",
      });
    }

    // Get MySQL connection with retry mechanism
    let pool = await poolPromise;

    if (!pool) {
      console.log("First connection attempt failed, trying to recreate pool...");
      pool = await recreatePool();
    }

    if (!pool) {
      console.log("Database not available - connection failed");
      return res.status(500).json({
        success: false,
        message: "Database service is currently unavailable. Please ensure MySQL user 'sqlserver' exists with password 'TalentPivot@1'.",
      });
    }

    // Check if user already exists
    console.log(`Checking if user already exists: ${email}`);
    const [existingUsers]: any = await pool.execute(
      'SELECT * FROM panel_info WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      console.log("User already exists, aborting registration.");
      return res.status(400).json({
        success: false,
        message: "User already exists.",
      });
    }

    // Hash the password
    console.log("Hashing password...");
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log("Password hashed successfully.");

    // Prepare user object
    const newUser: User = {
      full_name,
      email,
      phone: phone ? Number(phone) : null,
      experience: role === "HR" ? null : Number(experience),
      band: role === "HR" ? null : band,
      skill: role === "HR" ? null : skill,
      password: hashedPassword,
      role,
    };

    console.log("Prepared newUser object for insertion:", newUser);

    // Insert into MySQL
    try {
      console.log("Attempting to insert newUser into MySQL...");
      await pool.execute(
        `INSERT INTO panel_info
         (full_name, email, phone, experience, band, skill, password_hash, role)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          newUser.full_name,
          newUser.email,
          newUser.phone,
          newUser.experience,
          newUser.band,
          newUser.skill,
          newUser.password,
          newUser.role
        ]
      );

      console.log("Insertion into MySQL successful.");
    } catch (error) {
      console.error("Register Error during MySQL insert:", error);
      return res.status(500).json({
        success: false,
        message: "MySQL insertion failed.",
      });
    }

    console.log("User registration completed successfully.");
    return res.status(201).json({
      success: true,
      message: "User registered successfully.",
    });
  } catch (error) {
    console.error("Register Error (outer catch):", error);
    return res.status(500).json({
      success: false,
      message: "Server error during registration.",
    });
  }
};

// LOGIN USER
export const loginUser = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res
        .status(400)
        .json({ success: false, message: "Email and password are required." });
    }

    // Get MySQL connection
    const pool = await poolPromise;

    // Check if database is available
    if (!pool) {
      console.log("Database not available - using placeholder mode");
      return res.status(500).json({
        success: false,
        message: "Database service is currently unavailable. Please configure database credentials.",
      });
    }

    const [users]: any = await pool.execute(
      'SELECT * FROM panel_info WHERE email = ? LIMIT 1',
      [email]
    );

    const user = users[0];

    if (!user) {
      return res
        .status(401)
        .json({ success: false, message: "Invalid credentials." });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res
        .status(401)
        .json({ success: false, message: "Invalid credentials." });
    }

    // Generate JWT
    const payload = {
      email: user.email,
      role: user.role,
    };

    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    return res.status(200).json({
      success: true,
      message: "Login successful.",
      token,
      user: payload,
    });
  } catch (error) {
    console.error("Login Error:", error);
    return res
      .status(500)
      .json({ success: false, message: "Server error during login." });
  }
};
