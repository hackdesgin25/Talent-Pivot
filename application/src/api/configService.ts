// Service discovery and configuration utility
export interface ServiceEndpoints {
  backend: string;
  frontend: string;
  database?: string;
}

export class ConfigService {
  private static instance: ConfigService;
  private endpoints: ServiceEndpoints | null = null;

  private constructor() {}

  static getInstance(): ConfigService {
    if (!ConfigService.instance) {
      ConfigService.instance = new ConfigService();
    }
    return ConfigService.instance;
  }

  /**
   * Discover backend endpoint dynamically
   */
  async discoverBackendURL(): Promise<string> {
    // Try environment variable first
    if (import.meta.env.VITE_API_URL) {
      return import.meta.env.VITE_API_URL;
    }

    // For development, try common local ports
    if (import.meta.env.DEV) {
      const localPorts = [8080, 3000, 4000, 5000];
      for (const port of localPorts) {
        try {
          const testUrl = `http://localhost:${port}/api/v1/__health`;
          const response = await fetch(testUrl, { 
            method: 'GET',
            signal: AbortSignal.timeout(2000) // 2 second timeout
          });
          if (response.ok) {
            console.log(`✅ Found local backend at port ${port}`);
            return `http://localhost:${port}/api/v1`;
          }
        } catch (error) {
          // Port not available, continue
          console.debug(`Port ${port} not available:`, error);
        }
      }
    }

    // Fallback to production endpoint
    return 'https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1';
  }

  /**
   * Initialize service discovery
   */
  async initialize(): Promise<ServiceEndpoints> {
    if (this.endpoints) {
      return this.endpoints;
    }

    const backendUrl = await this.discoverBackendURL();
    
    this.endpoints = {
      backend: backendUrl,
      frontend: window.location.origin,
    };

    console.log('🔍 Service Discovery Complete:', this.endpoints);
    return this.endpoints;
  }

  getBackendURL(): string {
    return this.endpoints?.backend || 'https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1';
  }
}

export default ConfigService;
