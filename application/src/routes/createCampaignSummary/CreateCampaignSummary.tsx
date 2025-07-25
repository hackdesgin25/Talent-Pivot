/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLocation, useNavigate } from "react-router-dom";
import toast, { Toaster } from "react-hot-toast";
import { useState } from "react";
import { Container, Row, Col, Card, Button, Spinner } from "react-bootstrap";
import axiosInstance from "../../api/axiosInstance";
import { getLoggedInUserEmail } from "../../components/getLoggedInUserEmail/getLoggedInUserEmail";

const CreateCampaignSummary = () => {
  const { state } = useLocation();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  const email = getLoggedInUserEmail();

  if (!email) {
    toast.error("Session expired. Please login again.");
    navigate("/");
    return null;
  }

  if (!state) {
    toast.error("No campaign data found. Please fill the form first.");
    navigate("/create-campaign");
    return null;
  }

  const handleConfirmSubmit = async () => {
    setLoading(true);
    try {
      const formData = new FormData();

      // Append simple fields
      formData.append("campaignName", state.campaignName);
      formData.append("note", state.note || "");
      formData.append("startDate", state.startDate);
      formData.append("endDate", state.endDate);
      formData.append("hr_email", email);

      // Append arrays as JSON strings (align with updated structure)
      formData.append("l2", JSON.stringify(state.l2s));
      formData.append("l3", JSON.stringify(state.l3s));
      formData.append("l1s", JSON.stringify(state.l1s));
      formData.append("hrs", JSON.stringify(state.hrs));

      // Append JD files
      if (state.jdFiles && state.jdFiles.length > 0) {
        state.jdFiles.forEach((file: File) => {
          formData.append("jdFiles", file);
        });
      }

      const response = await axiosInstance.post("campaign", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      const data = response.data;

      if (data.success) {
        toast.success("Campaign created successfully!");
        navigate("/create-campaign/success", { state });
      } else {
        toast.error(data.message || "Failed to create campaign.");
      }
    } catch (error: any) {
      console.error("Error creating campaign:", error);
      toast.error(
        error?.response?.data?.message ||
          "Failed to create campaign. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    navigate("/create-campaign", { state });
  };

  return (
    <Container className="py-5">
      <Toaster position="top-center" />
      <h2 className="text-center mb-2">Review Campaign Details</h2>
      <p className="text-center text-muted mb-4">
        Please review the details before submission.
      </p>
      <Row className="justify-content-center">
        <Col xs={12} md={8} lg={6}>
          <Card className="shadow-sm p-4">
            <Card.Body className="text-center">
              <p>
                <strong>Name:</strong> {state.campaignName}
              </p>
              <p>
                <strong>Note:</strong> {state.note || "N/A"}
              </p>
              <p>
                <strong>Start Date:</strong> {state.startDate}
              </p>
              <p>
                <strong>End Date:</strong> {state.endDate}
              </p>

              {state.l2s.length > 0 && (
                <>
                  <p>
                    <strong>L2s:</strong>
                  </p>
                  <ul className="list-unstyled">
                    {state.l2s.map((email: string, idx: number) => (
                      <li key={idx}>{email}</li>
                    ))}
                  </ul>
                </>
              )}

              {state.l3s.length > 0 && (
                <>
                  <p>
                    <strong>L3s:</strong>
                  </p>
                  <ul className="list-unstyled">
                    {state.l3s.map((email: string, idx: number) => (
                      <li key={idx}>{email}</li>
                    ))}
                  </ul>
                </>
              )}

              {state.l1s.length > 0 && (
                <>
                  <p>
                    <strong>L1s:</strong>
                  </p>
                  <ul className="list-unstyled">
                    {state.l1s.map((email: string, idx: number) => (
                      <li key={idx}>{email}</li>
                    ))}
                  </ul>
                </>
              )}

              {state.hrs.length > 0 && (
                <>
                  <p>
                    <strong>HRs:</strong>
                  </p>
                  <ul className="list-unstyled">
                    {state.hrs.map((email: string, idx: number) => (
                      <li key={idx}>{email}</li>
                    ))}
                  </ul>
                </>
              )}

              {state.jdFiles.length > 0 && (
                <>
                  <p>
                    <strong>JD Files:</strong>
                  </p>
                  <div className="d-flex flex-wrap gap-2 justify-content-center">
                    {state.jdFiles.map((file: File, idx: number) => (
                      <span
                        key={idx}
                        className="badge bg-primary text-wrap p-2"
                      >
                        <i className="bi bi-file-earmark me-1"></i>
                        {file.name}
                      </span>
                    ))}
                  </div>
                </>
              )}
            </Card.Body>
          </Card>

          <div className="d-flex justify-content-between mt-4">
            <Button variant="secondary" onClick={handleBack} disabled={loading}>
              Back to Edit
            </Button>
            <Button
              variant="success"
              onClick={handleConfirmSubmit}
              disabled={loading}
            >
              {loading ? (
                <>
                  <Spinner
                    as="span"
                    animation="border"
                    size="sm"
                    role="status"
                    aria-hidden="true"
                  />{" "}
                  Submitting...
                </>
              ) : (
                "Confirm & Submit"
              )}
            </Button>
          </div>
        </Col>
      </Row>
    </Container>
  );
};

export default CreateCampaignSummary;
