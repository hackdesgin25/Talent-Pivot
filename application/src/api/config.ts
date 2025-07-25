// Dynamic API URL configuration with runtime detection
const getBaseURL = (): string => {
  // 1. Check for explicit environment variable first
  if (import.meta.env.VITE_API_URL) {
    console.log('Using VITE_API_URL:', import.meta.env.VITE_API_URL);
    return import.meta.env.VITE_API_URL;
  }
  
  // 2. Auto-detect based on current host for development
  if (import.meta.env.DEV) {
    const currentHost = window.location.hostname;
    if (currentHost === 'localhost' || currentHost === '127.0.0.1') {
      console.log('Development mode detected, using localhost backend');
      return 'http://localhost:8080/api/v1';
    }
  }
  
  // 3. Check build mode for different environments
  const mode = import.meta.env.MODE;
  
  switch (mode) {
    case 'development':
      return 'http://localhost:8080/api/v1';
    case 'staging':
      return 'https://talentpivot-backend-staging.us-central1.run.app/api/v1';
    case 'production':
      return 'https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1';
    default:
      // 4. Final fallback - use the latest deployed backend
      console.log('Using fallback backend URL');
      return 'https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1';
  }
};

const BASE_URL = getBaseURL();

// Log the selected base URL for debugging
console.log('🌐 API Base URL:', BASE_URL);
console.log('🔧 Environment Mode:', import.meta.env.MODE);
console.log('📍 Development Mode:', import.meta.env.DEV);

export default BASE_URL;
