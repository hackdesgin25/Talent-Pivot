/* eslint-disable @typescript-eslint/no-explicit-any */
import { useEffect, useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../components/auth/useAuth";
import {
  Container,
  Row,
  Col,
  Card,
  Form,
  Button,
  Alert,
} from "react-bootstrap";
import axiosInstance from "../../api/axiosInstance";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const navigate = useNavigate();
  const { login, isLoggedIn } = useAuth();

  useEffect(() => {
    if (isLoggedIn) {
      navigate("/campaigns");
    }
  }, [navigate, isLoggedIn]);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!email) {
      setError("Email is required.");
      return;
    }
    if (!emailRegex.test(email)) {
      setError("Please enter a valid email address.");
      return;
    }
    if (!password) {
      setError("Password is required.");
      return;
    }
    if (password.length < 8) {
      setError("Password must be at least 8 characters long.");
      return;
    }

    try {
      console.log("Attempting API login:", { email });

      const response = await axiosInstance.post(
        "/login",
        { email, password }
      );

      console.log("API response:", response.data);

      const { token, user } = response.data;

      login(token, user.role); // maintain your hook’s logic

      setSuccess("Login successful! Redirecting...");

      setEmail("");
      setPassword("");

      setTimeout(() => {
        navigate("/campaigns");
      }, 800);
    } catch (err: any) {
      console.error("Login API error:", err);

      if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else {
        setError("An error occurred during login. Please try again.");
      }
    }
  };

  return (
    <Container
      fluid
      className="d-flex align-items-center justify-content-center vh-100 bg-light"
    >
      <Row className="w-100 justify-content-center">
        <Col xs={11} sm={8} md={6} lg={4}>
          <Card className="shadow border-0 p-3">
            <Card.Body>
              <div className="text-center mb-3">
                <img
                  src="src/assets/TP.png"
                  alt="TalentPivot"
                  width="220"
                  height="60"
                  className="mb-2"
                />
                <h3 className="fw-bold">Login to Talent Pivot</h3>
                <p className="text-muted small">
                  Enter your credentials to continue
                </p>
              </div>

              {error && (
                <Alert variant="danger" className="text-center py-2">
                  {error}
                </Alert>
              )}
              {success && (
                <Alert variant="success" className="text-center py-2">
                  {success}
                </Alert>
              )}

              <Form onSubmit={handleSubmit}>
                <Form.Group className="form-floating mb-3">
                  <Form.Control
                    type="email"
                    placeholder="name@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                  <Form.Label>Email address</Form.Label>
                </Form.Group>

                <Form.Group className="form-floating mb-3">
                  <Form.Control
                    type="password"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                  <Form.Label>Password</Form.Label>
                </Form.Group>

                <Button variant="primary" type="submit" className="w-100">
                  Login
                </Button>
              </Form>
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default Login;
