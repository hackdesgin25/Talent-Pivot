import { useAuth } from "../auth/useAuth";
import { useNavigate } from "react-router-dom";
import { Navbar, Nav, Container, Button } from "react-bootstrap";

const CustomNavbar = () => {
  const navigate = useNavigate();
  const { isLoggedIn, logout } = useAuth();

  const handleAuthAction = () => {
    if (isLoggedIn) {
      logout();
      navigate("/");
    } else {
      navigate("/");
    }
  };

  const handleRegister = () => {
    navigate("/register");
  };

  const handleLogoClick = () => {
    if (isLoggedIn) {
      navigate("/campaigns");
    } else {
      navigate("/");
    }
  };

  return (
    <Navbar bg="light" expand="md" className="shadow-sm">
      <Container>
        <Navbar.Brand
          onClick={handleLogoClick}
          style={{ cursor: "pointer", display: "flex", alignItems: "center" }}
        >
          <img
            src="src/assets/TP.png"
            alt="Talent Pivot Logo"
            height="40"
            className="d-inline-block align-top me-2"
          />
        </Navbar.Brand>
        <Nav className="ms-auto d-flex align-items-center gap-2">
          {!isLoggedIn && (
            <Button variant="outline-primary" onClick={handleRegister}>
              Register
            </Button>
          )}
          <Button
            variant={isLoggedIn ? "danger" : "primary"}
            onClick={handleAuthAction}
          >
            {isLoggedIn ? "Sign Out" : "Login"}
          </Button>
        </Nav>
      </Container>
    </Navbar>
  );
};

export default CustomNavbar;
