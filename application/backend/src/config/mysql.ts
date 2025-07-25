/* eslint-disable @typescript-eslint/no-explicit-any */
import mysql from "mysql2/promise";
import dotenv from "dotenv";
import { 
  logConnectionDiagnostics, 
  analyzeConnectionError 
} from "../utils/databaseLogger";

dotenv.config();

// MySQL connection configuration for Google Cloud SQL
const mysqlConfig = {
  host: '34.63.181.90',
  port: 3306,
  user: 'sqlserver',
  password: 'TalentPivot@1',
  database: 'candidate_hub',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true
  // Note: SSL is handled automatically by mysql2 for Google Cloud SQL
};

console.log('🔗 MySQL Configuration:', {
  host: mysqlConfig.host,
  port: mysqlConfig.port,
  database: mysqlConfig.database,
  user: mysqlConfig.user
});

// Create MySQL connection pool with retry logic
async function createConnectionWithRetry(retries = 3): Promise<mysql.Pool | null> {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      console.log(`🔄 MySQL connection attempt ${attempt}/${retries}...`);
      
      const pool = mysql.createPool(mysqlConfig);
      
      // Test the connection with a simple query
      const connection = await pool.getConnection();
      await connection.execute('SELECT 1 as test');
      console.log('✅ MySQL pool created and tested successfully');
      connection.release();
      
      return pool;
    } catch (error: any) {
      console.error(`❌ MySQL connection attempt ${attempt} failed:`, error.message);
      console.error('Full error details:', error);
      
      if (attempt === retries) {
        console.error('🚨 All MySQL connection attempts failed');
        await analyzeConnectionError(error);
        return null;
      }
      
      const delay = attempt * 2000; // Exponential backoff
      console.log(`⏳ Retrying in ${delay}ms...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  return null;
}

// Initialize the connection pool with proper error handling
let poolPromise: Promise<mysql.Pool | null>;

async function initializePool(): Promise<mysql.Pool | null> {
  try {
    console.log('🔧 Initializing MySQL connection pool...');
    return await createConnectionWithRetry();
  } catch (error: any) {
    console.error('❌ Failed to initialize MySQL pool:', error.message);
    return null;
  }
}

poolPromise = initializePool();

// Test connection function
async function testConnection(): Promise<{ success: boolean; error?: string }> {
  try {
    console.log('🧪 Testing MySQL database connection...');
    await logConnectionDiagnostics();
    
    const pool = await poolPromise;
    if (!pool) {
      throw new Error('Database pool not initialized');
    }
    
    const [rows] = await pool.execute('SELECT 1 as test');
    console.log('✅ MySQL connection test successful:', rows);
    
    return { success: true };
  } catch (error: any) {
    console.error('❌ MySQL connection test failed:', error.message);
    await analyzeConnectionError(error);
    return { success: false, error: error.message };
  }
}

// Export for use in other modules
export { poolPromise, testConnection, mysqlConfig };

// Function to recreate pool (useful for retry scenarios)
export async function recreatePool(): Promise<mysql.Pool | null> {
  console.log('🔄 Recreating MySQL connection pool...');
  poolPromise = initializePool();
  return await poolPromise;
}
