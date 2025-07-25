import { useNavigate } from "react-router-dom";
import { Container, Row, Col, Button } from "react-bootstrap";

const NotFound = () => {
  const navigate = useNavigate();

  const handleGoHome = () => {
    navigate("/");
  };

  return (
    <Container
      fluid
      className="vh-100 d-flex align-items-center justify-content-center bg-light"
    >
      <Row className="w-100 justify-content-center">
        <Col xs={11} sm={8} md={6} lg={4} className="text-center">
          <h1 className="display-1 fw-bold text-primary mb-3">404</h1>
          <p className="lead mb-4 text-muted">
            Oops! The page you are looking for does not exist.
          </p>
          <Button variant="primary" onClick={handleGoHome}>
            Go Back Home
          </Button>
        </Col>
      </Row>
    </Container>
  );
};

export default NotFound;
