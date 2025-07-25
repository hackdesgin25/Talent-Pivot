import { type ReactNode, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/useAuth";
import Loader from "../loader/Loader";

const RequireAuth = ({ children }: { children: ReactNode }) => {
  const { isLoggedIn, loading } = useAuth(); // Add loading state
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading && !isLoggedIn) {
      navigate("/");
    }
  }, [isLoggedIn, loading, navigate]);

  if (loading) {
    return <Loader />; // show loader while checking auth
  }

  return <>{children}</>;
};

export default RequireAuth;
