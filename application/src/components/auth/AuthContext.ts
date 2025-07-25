import { createContext } from "react";

interface AuthContextType {
  isLoggedIn: boolean;
  login: (token: string, role: string) => void;
  logout: () => void;
  role: string | null;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export default AuthContext;
