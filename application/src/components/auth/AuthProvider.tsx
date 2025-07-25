import { type ReactNode, useEffect, useState } from "react";
import Cookies from "js-cookie";
import AuthContext from "./AuthContext";

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [role, setRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = Cookies.get("token");
    const userRole = Cookies.get("role");

    if (token) {
      setIsLoggedIn(true);
      setRole(userRole ?? null);
    }
  }, []);

  useEffect(() => {
    const token = Cookies.get("token");
    const userRole = Cookies.get("role");

    if (token) {
      setIsLoggedIn(true);
      setRole(userRole ?? null);
    }
    setLoading(false);
  }, []);

  const login = (token: string, role: string) => {
    Cookies.set("token", token, { expires: 1 });
    Cookies.set("role", role, { expires: 1 });

    setIsLoggedIn(true);
    setRole(role);

    console.log("Logged in, token and role set in cookies and state");
  };

  const logout = () => {
    Cookies.remove("token");
    Cookies.remove("role");

    setIsLoggedIn(false);
    setRole(null);

    console.log("Logged out, cookies cleared, state reset");
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, login, logout, role, loading }}>
      {children}
    </AuthContext.Provider>
  );
};
