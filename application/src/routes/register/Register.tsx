/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, type FormEvent } from "react";
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
import { useNavigate } from "react-router";

const Register = () => {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [phone, setPhone] = useState("");
  const [experience, setExperience] = useState("");
  const [band, setBand] = useState("");
  const [skill, setSkill] = useState("");
  const [role, setRole] = useState("HR");
  const navigate = useNavigate();

  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

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

    // Full name and phone are required for all roles
    if (!fullName) {
      setError("Full Name is required for all roles.");
      return;
    }
    if (!phone) {
      setError("Phone number is required for all roles.");
      return;
    }

    // Experience, band, and skill only for Manager & L1
    if (role !== "HR") {
      if (!experience) {
        setError("Experience is required for L1 and Manager.");
        return;
      }
      if (!band) {
        setError("Band is required for L1 and Manager.");
        return;
      }
      if (!skill) {
        setError("Skill is required for L1 and Manager.");
        return;
      }
    }

    const payload = {
      full_name: fullName,
      email,
      password,
      phone,
      experience: role === "HR" ? null : experience,
      band: role === "HR" ? null : band,
      skill: role === "HR" ? null : skill,
      role,
    };

    console.log(payload);

    try {
      setLoading(true);
      const response = await axiosInstance.post("/register", payload);
      alert(response);
      if (response.data.success) {
        setSuccess("Registration successful!");
        setFullName("");
        setEmail("");
        setPassword("");
        setPhone("");
        setExperience("");
        setBand("");
        setSkill("");
        setRole("HR");

        setTimeout(() => {
          navigate("/");
        }, 800);
      } else {
        setError(response.data.message || "Registration failed.");
      }
    } catch (error: any) {
      console.error("Registration Error:", error);
      if (
        error.response &&
        error.response.data &&
        error.response.data.message
      ) {
        setError(error.response.data.message);
      } else {
        setError("Server error during registration. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  const isHR = role === "HR";

  return (
    <Container
      fluid
      className="d-flex align-items-center justify-content-center vh-100 bg-light"
    >
      <Row className="w-100 justify-content-center">
        <Col xs={11} sm={8} md={6} lg={5} xl={4}>
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
                <h3 className="fw-bold">Register to Talent Pivot</h3>
                <p className="text-muted small">
                  Create your account to proceed
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
                {/* Full Name */}
                <Form.Group className="form-floating mb-3">
                  <Form.Control
                    type="text"
                    placeholder="Full Name"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    required
                  />
                  <Form.Label>Full Name</Form.Label>
                </Form.Group>

                {/* Phone */}
                <Form.Group className="form-floating mb-3">
                  <Form.Control
                    type="tel"
                    placeholder="Phone Number"
                    value={phone}
                    onChange={(e) => {
                      const onlyNums = e.target.value
                        .replace(/[^0-9]/g, "")
                        .slice(0, 10);
                      setPhone(onlyNums);
                    }}
                    inputMode="numeric"
                    pattern="[0-9]{10}"
                    required
                  />
                  <Form.Label>Phone Number</Form.Label>
                </Form.Group>

                {/* Email */}
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

                {/* Password */}
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

                {/* Role Selector */}
                <Form.Group className="form-floating mb-3">
                  <Form.Select
                    aria-label="Select Role"
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                    required
                  >
                    <option value="HR">HR</option>
                    <option value="L1">L1</option>
                    <option value="L2">L2</option>
                    <option value="L3">L3</option>
                  </Form.Select>
                  <Form.Label>Select Role</Form.Label>
                </Form.Group>

                {/* Manager / L1 Additional Fields */}
                {!isHR && (
                  <>
                    <Form.Group className="form-floating mb-3">
                      <Form.Control
                        type="number"
                        placeholder="Experience (years)"
                        value={experience}
                        onChange={(e) => setExperience(e.target.value)}
                      />
                      <Form.Label>Experience (years)</Form.Label>
                    </Form.Group>

                    <Form.Group className="form-floating mb-3">
                      <Form.Select
                        aria-label="Select Band"
                        value={band}
                        onChange={(e) => setBand(e.target.value)}
                      >
                        <option value="">Select Band</option>
                        <option value="A">A</option>
                        <option value="B">B</option>
                        <option value="C">C</option>
                        <option value="D">D</option>
                        <option value="E">E</option>
                        <option value="F">F</option>
                      </Form.Select>
                      <Form.Label>Select Band (A-F)</Form.Label>
                    </Form.Group>

                    <Form.Group className="form-floating mb-3">
                      <Form.Control
                        type="text"
                        placeholder="Skills"
                        value={skill}
                        onChange={(e) => setSkill(e.target.value)}
                      />
                      <Form.Label>Skills (comma separated)</Form.Label>
                    </Form.Group>
                  </>
                )}

                <Button
                  type="submit"
                  variant="primary"
                  className="w-100"
                  disabled={loading}
                >
                  {loading ? (
                    <>
                      <span
                        className="spinner-border spinner-border-sm me-2"
                        role="status"
                        aria-hidden="true"
                      ></span>
                      Registering...
                    </>
                  ) : (
                    "Register"
                  )}
                </Button>
              </Form>
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default Register;
