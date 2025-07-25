import Cookies from "js-cookie";
import { jwtDecode } from "jwt-decode";

interface DecodedToken {
  email: string;
  role: string;
  exp: number;
  iat: number;
}

export const getLoggedInUserEmail = (): string | null => {
  const token = Cookies.get("token");
  if (!token) return null;

  try {
    const decoded: DecodedToken = jwtDecode(token);
    return decoded.email || null;
  } catch (error) {
    console.error("Failed to decode JWT", error);
    return null;
  }
};
