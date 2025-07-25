import { useLocation, useNavigate } from "react-router-dom";
import { Container, Row, Col, Card, Button, Badge } from "react-bootstrap";
import { CheckCircleFill } from "react-bootstrap-icons";

const CreateCampaignSuccess = () => {
  const { state } = useLocation();
  const navigate = useNavigate();

  if (!state) {
    navigate("/campaigns");
    return null;
  }

  const proceed = () => {
    navigate("/campaigns");
  };

  return (
    <Container
      className="d-flex justify-content-center align-items-center"
      style={{ minHeight: "80vh" }}
    >
      <Row className="w-100 justify-content-center">
        <Col xs={12} md={8} lg={6}>
          <Card className="text-center shadow p-4">
            {/* Center icon + heading inline */}
            <div className="d-flex align-items-center justify-content-center mb-3">
              <CheckCircleFill color="#28a745" size={36} className="me-2" />
              <h2 className="mb-0">Campaign Created Successfully 🎉</h2>
            </div>
            <p className="text-muted mb-4">
              Your campaign has been created and is now visible under your
              campaigns.
            </p>
            <Card className="text-start p-3 bg-light border-0">
              <p>
                <strong>Campaign Name:</strong>{" "}
                <Badge bg="secondary">{state.campaignName}</Badge>
              </p>
              <p>
                <strong>Start Date:</strong>{" "}
                <Badge bg="info">{state.startDate}</Badge>
              </p>
              <p>
                <strong>End Date:</strong>{" "}
                <Badge bg="info">{state.endDate}</Badge>
              </p>
            </Card>
            <Button variant="success" onClick={proceed} className="mt-4">
              Go to Campaigns
            </Button>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default CreateCampaignSuccess;
