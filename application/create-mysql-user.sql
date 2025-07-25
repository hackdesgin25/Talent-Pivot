-- TalentPivot MySQL User Setup
-- =============================
-- Run this in Google Cloud SQL Console or MySQL client

-- 1. Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS candidate_hub;

-- 2. Create the user (if it doesn't exist)
CREATE USER IF NOT EXISTS 'sqlserver'@'%' IDENTIFIED BY 'TalentPivot@1';

-- 3. Grant all privileges on the database
GRANT ALL PRIVILEGES ON candidate_hub.* TO 'sqlserver'@'%';

-- 4. Flush privileges to ensure changes take effect
FLUSH PRIVILEGES;

-- 5. Verify the user was created
SELECT User, Host FROM mysql.user WHERE User = 'sqlserver';

-- 6. Create the main table for user authentication
USE candidate_hub;

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

-- 7. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_email ON panel_info(email);
CREATE INDEX IF NOT EXISTS idx_role ON panel_info(role);

-- 8. Verify table structure
DESCRIBE panel_info;
