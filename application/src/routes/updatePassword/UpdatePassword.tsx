import { useState, type FormEvent } from "react";
import {
  Container,
  Row,
  Col,
  Card,
  Button,
  Alert,
  Form,
} from "react-bootstrap";

const UpdatePassword = () => {
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    if (!password || !confirmPassword) {
      setError("Both fields are required.");
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    if (password.length < 8) {
      setError("Password must be at least 8 characters long.");
      return;
    }

    console.log("Passwords match, proceed with update.");
    setSuccess("Password updated successfully!");
    setPassword("");
    setConfirmPassword("");
  };

  return (
    <Container className="d-flex align-items-center justify-content-center min-vh-100 bg-light">
      <Row className="w-100 justify-content-center">
        <Col xs={12} md={6} lg={4}>
          <Card className="shadow-sm p-4">
            <div className="text-center mb-3">
              <img
                src="src/assets/TP.png"
                alt="TalentPivot"
                width="250"
                height="65"
                className="mb-3"
              />
              <h3 className="fw-bold">Update Password</h3>
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
              <Form.Group className="mb-3" controlId="newPassword">
                <Form.Label>New Password</Form.Label>
                <Form.Control
                  type="password"
                  placeholder="Enter new password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </Form.Group>

              <Form.Group className="mb-4" controlId="confirmNewPassword">
                <Form.Label>Confirm New Password</Form.Label>
                <Form.Control
                  type="password"
                  placeholder="Confirm new password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                />
              </Form.Group>

              <Button type="submit" variant="primary" className="w-100">
                Update Password
              </Button>
            </Form>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default UpdatePassword;
