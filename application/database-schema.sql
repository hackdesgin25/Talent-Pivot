-- TalentPivot Database Schema for User Creation
-- ============================================

-- First, ensure you have the database
CREATE DATABASE IF NOT EXISTS candidate_hub;
USE candidate_hub;

-- Create the users table (panel_info)
CREATE TABLE IF NOT EXISTS panel_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone BIGINT,
    experience INT,
    band VARCHAR(100),
    skill TEXT,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('HR', 'candidate') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_email ON panel_info(email);
CREATE INDEX idx_role ON panel_info(role);

-- Example: Insert a test HR user (password is 'admin123')
INSERT INTO panel_info (full_name, email, phone, password_hash, role) VALUES 
('Admin User', 'admin@talentpivot.com', 1234567890, '$2b$10$abcdefghijklmnopqrstuvwxyz', 'HR');

-- Example: Insert a test candidate (password is 'candidate123')
INSERT INTO panel_info (full_name, email, phone, experience, band, skill, password_hash, role) VALUES 
('Test Candidate', 'candidate@talentpivot.com', 9876543210, 3, 'Mid-Level', 'JavaScript, Python', '$2b$10$abcdefghijklmnopqrstuvwxyz', 'candidate');
