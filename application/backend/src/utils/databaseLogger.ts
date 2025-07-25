// Database Query Logger Helper
// Add this to your backend controllers to log database operations

export const logDatabaseQuery = (operation: string, query: string, params?: any) => {
  console.log(`🗄️ [DATABASE] ${operation.toUpperCase()}`);
  console.log(`📝 Query: ${query}`);
  if (params) {
    console.log(`📋 Parameters:`, JSON.stringify(params, null, 2));
  }
  console.log(`⏰ Timestamp: ${new Date().toISOString()}`);
};

export const logDatabaseResult = (operation: string, result: any, executionTime?: number) => {
  console.log(`✅ [DATABASE] ${operation.toUpperCase()} - SUCCESS`);
  console.log(`📊 Result count: ${Array.isArray(result) ? result.length : 'Single record'}`);
  if (executionTime) {
    console.log(`⚡ Execution time: ${executionTime}ms`);
  }
  console.log(`⏰ Completed at: ${new Date().toISOString()}`);
};

export const logDatabaseError = (operation: string, error: any) => {
  console.error(`❌ [DATABASE] ${operation.toUpperCase()} - ERROR`);
  console.error(`🚨 Error message: ${error.message}`);
  console.error(`🔍 Error details:`, error);
  console.error(`⏰ Error time: ${new Date().toISOString()}`);
};

// Enhanced connection diagnostics logger
export const logConnectionDiagnostics = () => {
  console.log('\n🔧 [DATABASE DIAGNOSTICS] Connection Configuration');
  console.log('==========================================');
  console.log(`📍 SQL_HOST: ${process.env.SQL_HOST || 'NOT SET'}`);
  console.log(`🔌 SQL_PORT: ${process.env.SQL_PORT || 'NOT SET'}`);
  console.log(`🗄️ SQL_DATABASE: ${process.env.SQL_DATABASE || 'NOT SET'}`);
  console.log(`👤 SQL_USER: ${process.env.SQL_USER || 'NOT SET'}`);
  console.log(`🔑 SQL_PASSWORD: ${process.env.SQL_PASSWORD ? '***SET***' : 'NOT SET'}`);
  console.log(`🌍 NODE_ENV: ${process.env.NODE_ENV || 'NOT SET'}`);
  console.log(`⏰ Timestamp: ${new Date().toISOString()}`);
  console.log('==========================================\n');
};

// Connection retry logger
export const logConnectionRetry = (attempt: number, maxAttempts: number, delay: number) => {
  console.log(`🔄 [CONNECTION RETRY] Attempt ${attempt}/${maxAttempts}`);
  console.log(`⏱️ Waiting ${delay}ms before retry...`);
  console.log(`⏰ Timestamp: ${new Date().toISOString()}`);
};

// Connection failure analysis
export const analyzeConnectionError = (error: any) => {
  console.error('\n🔍 [CONNECTION ANALYSIS] Detailed Error Analysis');
  console.error('===============================================');
  
  if (error.message) {
    console.error(`📝 Error Message: ${error.message}`);
  }
  
  if (error.code) {
    console.error(`🏷️ Error Code: ${error.code}`);
    
    // Common MySQL error codes
    switch (error.code) {
      case 'ETIMEDOUT':
      case 'ETIMEOUT':
        console.error('🚨 Analysis: Connection timeout - server may be unreachable or overloaded');
        console.error('💡 Solutions:');
        console.error('   - Check if the server IP address is correct: 34.63.181.90');
        console.error('   - Verify firewall settings allow connections on port 3306');
        console.error('   - Ensure MySQL server is running and accepting connections');
        console.error('   - Check Cloud SQL authorized networks');
        break;
      case 'ECONNREFUSED':
        console.error('🚨 Analysis: Connection refused - server actively rejected the connection');
        console.error('💡 Solutions:');
        console.error('   - Verify MySQL server is running');
        console.error('   - Check if the port number is correct (3306 for MySQL)');
        console.error('   - Ensure Cloud SQL instance is not paused');
        break;
      case 'ENOTFOUND':
        console.error('🚨 Analysis: Host not found - DNS resolution failed');
        console.error('💡 Solutions:');
        console.error('   - Verify the server hostname/IP address: 34.63.181.90');
        console.error('   - Check network connectivity from Cloud Run');
        break;
      case 'ER_ACCESS_DENIED_ERROR':
        console.error('🚨 Analysis: Authentication failed');
        console.error('💡 Solutions:');
        console.error('   - Verify username and password');
        console.error('   - Check if MySQL user exists and has permissions');
        console.error('   - Ensure user can connect from Cloud Run IP ranges');
        break;
      case 'ER_BAD_DB_ERROR':
        console.error('🚨 Analysis: Database does not exist');
        console.error('💡 Solutions:');
        console.error('   - Verify database name: candidate_hub');
        console.error('   - Create the database if it doesn\'t exist');
        break;
      case 'PROTOCOL_CONNECTION_LOST':
        console.error('🚨 Analysis: Connection was lost during query');
        console.error('💡 Solutions:');
        console.error('   - Check for network instability');
        console.error('   - Consider implementing connection retry logic');
        break;
      default:
        console.error(`🚨 Analysis: MySQL error code - ${error.code}`);
        console.error('💡 Check MySQL documentation for this error code');
    }
  }
  
  console.error(`⏰ Analysis time: ${new Date().toISOString()}`);
  console.error('===============================================\n');
};

// Example usage in your controllers:
/*
import { logDatabaseQuery, logDatabaseResult, logDatabaseError } from './logger';

// In your controller function:
export const getCampaigns = async (req: Request, res: Response) => {
  const startTime = Date.now();
  
  try {
    const query = "SELECT * FROM campaigns WHERE user_id = ?";
    const params = [req.user.id];
    
    logDatabaseQuery('SELECT_CAMPAIGNS', query, params);
    
    const result = await pool.request()
      .input('userId', sql.VarChar, req.user.id)
      .query(query);
    
    const executionTime = Date.now() - startTime;
    logDatabaseResult('SELECT_CAMPAIGNS', result.recordset, executionTime);
    
    res.json({ success: true, data: result.recordset });
  } catch (error) {
    logDatabaseError('SELECT_CAMPAIGNS', error);
    res.status(500).json({ error: 'Database operation failed' });
  }
};
*/
