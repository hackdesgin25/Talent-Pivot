import axios from "axios";
import Cookies from "js-cookie";
import ConfigService from "./configService";

// Initialize config service
const configService = ConfigService.getInstance();

// Create axios instance with dynamic base URL
const createAxiosInstance = async () => {
  await configService.initialize();
  
  const instance = axios.create({
    baseURL: configService.getBackendURL(),
    withCredentials: false,
    headers: {
      "Content-Type": "application/json",
    },
  });

  // Request interceptor for auth token
  instance.interceptors.request.use(
    (config) => {
      const token = Cookies.get("token");
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => Promise.reject(error)
  );

  // Response interceptor for error handling
  instance.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        // Handle unauthorized - clear tokens and redirect
        Cookies.remove("token");
        Cookies.remove("role");
        window.location.href = "/";
      }
      return Promise.reject(error);
    }
  );

  return instance;
};

// Export a promise that resolves to the configured axios instance
export const axiosInstancePromise = createAxiosInstance();

// For backward compatibility, export a synchronous instance
// This will use the fallback URL until service discovery completes
const axiosInstance = axios.create({
  baseURL: configService.getBackendURL(),
  withCredentials: false,
  headers: {
    "Content-Type": "application/json",
  },
});

axiosInstance.interceptors.request.use(
  (config) => {
    const token = Cookies.get("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export default axiosInstance;
