/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import {
  Container,
  Row,
  Col,
  Form,
  Button,
  Card,
  Badge,
  Spinner,
} from "react-bootstrap";
import toast from "react-hot-toast";

const CreateCampaignPage = () => {
  const [campaignName, setCampaignName] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [jdFiles, setJdFiles] = useState<File[]>([]);
  const [note, setNote] = useState("");

  const [l2s, setL2s] = useState([{ email: "" }]);
  const [l3s, setL3s] = useState([{ email: "" }]); // L3 required
  const [l1s, setL1s] = useState([{ email: "" }]);
  const [hrs, setHrs] = useState([{ email: "" }]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const navigate = useNavigate();
  const location = useLocation();

  // Load state on returning back
  useEffect(() => {
    if (location.state) {
      const state = location.state as any;
      setCampaignName(state.campaignName ?? "");
      setStartDate(state.startDate ?? "");
      setEndDate(state.endDate ?? "");
      setNote(state.note ?? "");
      setL2s(state.l2s ?? [{ email: "" }]);
      setL3s(state.l3s ?? [{ email: "" }]);
      setL1s(state.l1s ?? [{ email: "" }]);
      setHrs(state.hrs ?? [{ email: "" }]);
    }
  }, [location.state]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const allowedTypes = ["application/pdf"];
      const maxSize = 10 * 1024 * 1024; // 10 MB

      const filesArray = Array.from(e.target.files);

      const invalidFiles = filesArray.filter(
        (file) => !allowedTypes.includes(file.type) || file.size > maxSize
      );

      if (invalidFiles.length > 0) {
        setError("Only PDF files up to 10 MB are allowed.");
        e.target.value = ""; // clear the input so user can reselect
        return;
      }

      setError(null);
      setJdFiles(filesArray);
    }
  };

  const addField = (type: "l2" | "l3" | "l1" | "hr") => {
    const newField = { email: "" };
    if (type === "l2") setL2s([...l2s, newField]);
    if (type === "l3") setL3s([...l3s, newField]);
    if (type === "l1") setL1s([...l1s, newField]);
    if (type === "hr") setHrs([...hrs, newField]);
  };

  const deleteField = (type: "l2" | "l3" | "l1" | "hr", idx: number) => {
    if (type === "l3") {
      if (l3s.length === 1) {
        alert("At least one L3 is required.");
        return;
      }
      setL3s(l3s.filter((_, i) => i !== idx));
    }
    if (type === "l2") setL2s(l2s.filter((_, i) => i !== idx));
    if (type === "l1") setL1s(l1s.filter((_, i) => i !== idx));
    if (type === "hr") setHrs(hrs.filter((_, i) => i !== idx));
  };

  const handleChange = (
    type: "l2" | "l3" | "l1" | "hr",
    idx: number,
    value: string
  ) => {
    const list =
      type === "l2"
        ? [...l2s]
        : type === "l3"
        ? [...l3s]
        : type === "l1"
        ? [...l1s]
        : [...hrs];
    list[idx].email = value;
    if (type === "l2") setL2s(list);
    if (type === "l3") setL3s(list);
    if (type === "l1") setL1s(list);
    if (type === "hr") setHrs(list);
  };

  const validateEmails = (list: { email: string }[]) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    for (const item of list) {
      if (item.email && !emailRegex.test(item.email)) {
        return false;
      }
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!campaignName || !startDate || !endDate) {
      setError("Please fill all required fields.");
      return;
    }
    if (new Date(endDate) < new Date(startDate)) {
      setError("End date cannot be before start date.");
      return;
    }
    if (jdFiles.length === 0) {
      setError("Please upload at least one JD file.");
      return;
    }
    if (
      !validateEmails(l2s) ||
      !validateEmails(l3s) ||
      !validateEmails(l1s) ||
      !validateEmails(hrs)
    ) {
      setError("Please enter valid email addresses.");
      return;
    }
    if (l3s.filter((l) => l.email.trim() !== "").length === 0) {
      setError("At least one L3 email is required.");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const payload = {
        campaignName,
        startDate,
        endDate,
        note,
        l2s: l2s.map((l) => l.email).filter(Boolean),
        l3s: l3s.map((l) => l.email).filter(Boolean),
        l1s: l1s.map((l) => l.email).filter(Boolean),
        hrs: hrs.map((h) => h.email).filter(Boolean),
        jdFiles,
      };

      toast.dismiss();
      navigate("/create-campaign/summary", { state: payload });
    } catch (error) {
      toast.dismiss();
      console.log(error);
      toast.error("Failed to create campaign. Try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container fluid className="py-4 px-3 bg-light min-vh-100">
      <Container className="p-4 bg-white rounded shadow">
        <h2 className="mb-4 text-center">Create Campaign</h2>
        {error && <div className="alert alert-danger">{error}</div>}
        <Form onSubmit={handleSubmit}>
          <Form.Group className="mb-3">
            <Form.Label>Campaign Name</Form.Label>
            <Form.Control
              type="text"
              placeholder="e.g., July Developer Hiring"
              value={campaignName}
              onChange={(e) => setCampaignName(e.target.value)}
              required
            />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Note (Optional)</Form.Label>
            <Form.Control
              as="textarea"
              rows={3}
              placeholder="Add any additional notes for this campaign"
              value={note}
              onChange={(e) => setNote(e.target.value)}
            />
          </Form.Group>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Start Date</Form.Label>
                <Form.Control
                  type="date"
                  min={new Date().toISOString().split("T")[0]}
                  value={startDate}
                  onChange={(e) => setStartDate(e.target.value)}
                  required
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>End Date</Form.Label>
                <Form.Control
                  type="date"
                  min={startDate || new Date().toISOString().split("T")[0]}
                  value={endDate}
                  onChange={(e) => setEndDate(e.target.value)}
                  required
                />
              </Form.Group>
            </Col>
          </Row>

          <Form.Group className="mb-4">
            <Form.Label>Upload JD(s)</Form.Label>
            <Form.Control
              type="file"
              multiple
              accept=".pdf,.doc,.docx"
              onChange={handleFileChange}
              required
            />
            <div className="mt-2">
              {jdFiles.map((file, idx) => (
                <Badge bg="secondary" className="me-1" key={idx}>
                  {file.name}
                </Badge>
              ))}
            </div>
          </Form.Group>

          {[
            { label: "L2 (Optional)", type: "l2", data: l2s },
            { label: "L3 (Required)", type: "l3", data: l3s },
            { label: "L1 (Optional)", type: "l1", data: l1s },
            { label: "HR (Optional)", type: "hr", data: hrs },
          ].map((section, idx) => (
            <Card className="mb-3" key={idx}>
              <Card.Body>
                <Card.Title>{section.label}</Card.Title>
                {section.data.map((item, i) => (
                  <Row className="mb-2" key={i} align="center">
                    <Col md={10}>
                      <Form.Control
                        type="email"
                        placeholder="Email"
                        value={item.email}
                        onChange={(e) =>
                          handleChange(section.type as any, i, e.target.value)
                        }
                      />
                    </Col>
                    <Col md={2}>
                      <Button
                        variant="outline-danger"
                        size="sm"
                        onClick={() => deleteField(section.type as any, i)}
                      >
                        Delete
                      </Button>
                    </Col>
                  </Row>
                ))}
                <Button
                  variant="outline-primary"
                  size="sm"
                  onClick={() => addField(section.type as any)}
                >
                  Add Email
                </Button>
              </Card.Body>
            </Card>
          ))}

          <div className="d-grid">
            <Button
              type="submit"
              variant="success"
              disabled={loading}
              size="lg"
            >
              {loading ? (
                <Spinner animation="border" size="sm" />
              ) : (
                "Create Campaign"
              )}
            </Button>
          </div>
        </Form>
      </Container>
    </Container>
  );
};

export default CreateCampaignPage;
