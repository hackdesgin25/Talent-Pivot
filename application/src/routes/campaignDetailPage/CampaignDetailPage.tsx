import { useParams } from "react-router-dom";
import { useState, useEffect, useCallback } from "react";
import {
  Container,
  Table,
  Button,
  Form,
  Row,
  Col,
  Badge,
  Card,
  Pagination,
  Spinner,
} from "react-bootstrap";
import { Pie, Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
} from "chart.js";
import axiosInstance from "../../api/axiosInstance";
import toast from "react-hot-toast";
import Cookies from "js-cookie";
import { useDebounce } from "../../hooks/useDebounce";

// Chart.js registration
ChartJS.register(
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement
);

// Constants
const statuses = ["All", "Pending", "Completed", "Rejected"];
const itemsPerPage = 10;

// Candidate type
interface Candidate {
  candidate_id: string;
  full_name: string;
  email_id: string;
  phone: string;
  app_status: string;
  l1_status: string;
  l1_feedback: string;
  l2_status: string;
  l2_feedback: string;
  l3_status: string;
  l3_feedback: string;
  hr_status: string;
  hr_feedback: string;
}

const CampaignDetailPage = () => {
  const { id: campaignId } = useParams<{ id: string }>();

  const [candidates, setCandidates] = useState<Candidate[]>([]);
  const [loading, setLoading] = useState(false);

  // Add role states
  const [newL2, setNewL2] = useState("");
  const [newL3, setNewL3] = useState("");
  const [showL2Input, setShowL2Input] = useState(false);
  const [showL3Input, setShowL3Input] = useState(false);
  const [newL1, setNewL1] = useState("");
  const [newHR, setNewHR] = useState("");
  const [showL1Input, setShowL1Input] = useState(false);
  const [showHRInput, setShowHRInput] = useState(false);

  // Filters
  const [filterName, setFilterName] = useState("");
  const [filterEmail, setFilterEmail] = useState("");
  const [filterPhone, setFilterPhone] = useState("");

  const debouncedFilterName = useDebounce(filterName, 300);
  const debouncedFilterEmail = useDebounce(filterEmail, 300);
  const debouncedFilterPhone = useDebounce(filterPhone, 300);
  const [filterStatus, setFilterStatus] = useState("All");

  const [currentPage, setCurrentPage] = useState(1);

  const [showAddCandidate, setShowAddCandidate] = useState(false);
  const [newCandidateName, setNewCandidateName] = useState("");
  const [newCandidateEmail, setNewCandidateEmail] = useState("");
  const [newCandidatePhone, setNewCandidatePhone] = useState("");
  const [newCandidateResume, setNewCandidateResume] = useState<File | null>(
    null
  );
  const [addingCandidate, setAddingCandidate] = useState(false);
  const [editedStatus, setEditedStatus] = useState<
    Record<string, Partial<Candidate>>
  >({});
  const [actionLoading, setActionLoading] = useState(false);
  const [campaignStatus, setCampaignStatus] = useState<"Active" | "Completed">(
    "Active"
  );
  const [isHR, setIsHR] = useState(false);
  const userRole = Cookies.get("role")?.toUpperCase();

  const fetchCampaignStatus = useCallback(async () => {
    try {
      const { data } = await axiosInstance.get(
        `/campaign/${campaignId}/status`
      );

      setCampaignStatus(data.status || "Active");
    } catch (error) {
      console.error("Error fetching campaign status:", error);
    }
  }, [campaignId]);
  /**
   * Fetch candidates for the campaign
   */
  const fetchCandidates = useCallback(async () => {
    setLoading(true);
    setActionLoading(true);
    try {
      const response = await axiosInstance.get(
        `/campaign/${campaignId}/candidates`
      );
      setCandidates(response.data.data || []);
    } catch (error) {
      console.error("Error fetching candidates:", error);
      toast.error("❌ Failed to fetch candidates");
    } finally {
      setLoading(false);
      setActionLoading(false);
    }
  }, [campaignId]);

  useEffect(() => {
    if (campaignId) {
      fetchCandidates();
      fetchCampaignStatus();

      setIsHR(userRole === "HR");
    }
  }, [campaignId, userRole, fetchCandidates, fetchCampaignStatus]);
  const isCompleted = campaignStatus === "Completed";
  /**
   * Filter candidates
   */
  const filteredCandidates = candidates.filter((c) => {
    const matchesName = c.full_name
      .toLowerCase()
      .includes(debouncedFilterName.toLowerCase());
    const matchesEmail = c.email_id
      .toLowerCase()
      .includes(debouncedFilterEmail.toLowerCase());
    const matchesPhone = c.phone.includes(debouncedFilterPhone);
    const matchesStatus =
      filterStatus === "All" ||
      c.app_status === filterStatus ||
      c.l1_status === filterStatus ||
      c.l2_status === filterStatus ||
      c.l3_status === filterStatus ||
      c.hr_status === filterStatus;

    return matchesName && matchesEmail && matchesPhone && matchesStatus;
  });

  const isValidEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const isValidPhone = (phone: string): boolean => {
    const phoneRegex = /^[0-9]{10}$/;
    return phoneRegex.test(phone);
  };

  const totalPages = Math.ceil(filteredCandidates.length / itemsPerPage);
  const currentCandidates = filteredCandidates.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const resetFilters = () => {
    setFilterName("");
    setFilterEmail("");
    setFilterPhone("");
    setFilterStatus("All");
    setCurrentPage(1);
  };

  /**
   * Other core handlers unchanged
   */
  const handleAddRole = async (role: "l2" | "l3" | "l1" | "hr") => {
    const email =
      role === "l2"
        ? newL2.trim()
        : role === "l3"
        ? newL3.trim()
        : role === "l1"
        ? newL1.trim()
        : newHR.trim();
    if (!email) {
      toast.error("❌ Email is required");
      return;
    }
    if (!isValidEmail(email)) {
      toast.error("❌ Please enter a valid email address.");
      return;
    }
    setActionLoading(true);
    try {
      await axiosInstance.post(`/campaign/${campaignId}/assign-role`, {
        role,
        email,
      });
      toast.success(`✅ ${role.toUpperCase()} added successfully!`);
      if (role === "l2") {
        setNewL2("");
        setShowL2Input(false);
      } else if (role === "l3") {
        setNewL3("");
        setShowL3Input(false);
      } else if (role === "l1") {
        setNewL1("");
        setShowL1Input(false);
      } else {
        setNewHR("");
        setShowHRInput(false);
      }
    } catch (error) {
      console.error(`Error adding ${role}:`, error);
      toast.error(`❌ Failed to add ${role}`);
    } finally {
      setActionLoading(false);
    }
  };

  const handleDownloadJD = async () => {
    try {
      setActionLoading(true); // optional loader during fetch
      const { data } = await axiosInstance.get(`/campaign/${campaignId}/jds`);

      if (data.signedUrls && data.signedUrls.length > 0) {
        data.signedUrls.forEach((url: string) => {
          window.open(url, "_blank");
        });
      } else {
        toast.error("❌ No JD files found for this campaign.");
      }
    } catch (error) {
      console.error(error);
      toast.error("❌ Failed to fetch JD files.");
    } finally {
      setActionLoading(false);
    }
  };

  const handleDownloadResume = async (candidateId: string) => {
    try {
      setActionLoading(true);
      const { data } = await axiosInstance.get(
        `/campaign/${campaignId}/candidate/${candidateId}/resume`
      );
      window.open(data.signedUrl, "_blank");
    } catch (error) {
      console.error(error);
      toast.error("❌ Failed to fetch resume URL.");
    } finally {
      setActionLoading(false);
    }
  };

  const handleCompleteCampaign = async () => {
    setActionLoading(true);
    try {
      await axiosInstance.post(`/campaign/${campaignId}/complete`);
      toast.success("✅ Campaign marked as complete!");
      fetchCampaignStatus();
    } catch (error) {
      console.error("Error completing campaign:", error);
      toast.error("❌ Failed to complete campaign");
    } finally {
      setActionLoading(false);
    }
  };

  /**
   * Audit Trail for Charts
   */
  const audit = {
    awaitingL1: candidates.filter((c) => c.l1_status === "Pending").length,
    awaitingL2: candidates.filter((c) => c.l2_status === "Pending").length,
    awaitingL3: candidates.filter((c) => c.l3_status === "Pending").length,
    awaitingHR: candidates.filter((c) => c.hr_status === "Pending").length,
    completed: candidates.filter((c) => c.hr_status === "Completed").length,
    rejected: candidates.filter((c) => c.hr_status === "Rejected").length,
    inProgress: candidates.filter((c) => c.app_status === "In Progress").length,
  };

  const pieData = {
    labels: [
      "Awaiting L1",
      "Awaiting L2",
      "Awaiting L3",
      "Awaiting HR",
      "Completed",
      "Rejected",
    ],
    datasets: [
      {
        data: [
          audit.awaitingL1,
          audit.awaitingL2,
          audit.awaitingL3,
          audit.awaitingHR,
          audit.completed,
          audit.rejected,
        ],
        backgroundColor: [
          "#FFCE56", // Awaiting L1
          "#36A2EB", // Awaiting L2
          "#FF9F40", // Awaiting L3
          "#FF6384", // Awaiting HR
          "#4CAF50", // Completed
          "#9C27B0", // Rejected
        ],
      },
    ],
  };

  const barData = {
    labels: [
      "In Progress",
      "Awaiting L1",
      "Awaiting L2",
      "Awaiting L3",
      "Awaiting HR",
      "Completed",
      "Rejected",
    ],
    datasets: [
      {
        label: "Candidates",
        backgroundColor: [
          "#2196F3", // In Progress
          "#FFCE56", // Awaiting L1
          "#36A2EB", // Awaiting L2
          "#FF9F40", // Awaiting L3
          "#FF6384", // Awaiting HR
          "#4CAF50", // Completed
          "#9C27B0", // Rejected
        ],
        data: [
          audit.inProgress,
          audit.awaitingL1,
          audit.awaitingL2,
          audit.awaitingL3,
          audit.awaitingHR,
          audit.completed,
          audit.rejected,
        ],
      },
    ],
  };

  const handleAddCandidate = async () => {
    if (!newCandidateName.trim()) {
      toast.error("❌ Name is required.");
      return;
    }
    if (!isValidEmail(newCandidateEmail.trim())) {
      toast.error("❌ Please enter a valid email.");
      return;
    }
    if (!isValidPhone(newCandidatePhone.trim())) {
      toast.error("❌ Please enter a valid phone number (10 digits).");
      return;
    }
    if (!newCandidateResume) {
      toast.error("❌ Please upload a resume.");
      return;
    }

    setAddingCandidate(true);
    setActionLoading(true);
    try {
      const formData = new FormData();
      formData.append("full_name", newCandidateName.trim());
      formData.append("email_id", newCandidateEmail.trim());
      formData.append("phone", newCandidatePhone.trim());
      formData.append("resume", newCandidateResume);
      const response = await axiosInstance.post(
        `/campaign/${campaignId}/add-candidate`,
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        }
      );

      if (response.status === 200) {
        toast.success("✅ Candidate added successfully!");
        setShowAddCandidate(false);
        setNewCandidateName("");
        setNewCandidateEmail("");
        setNewCandidatePhone("");
        setNewCandidateResume(null);
        fetchCandidates();
      } else {
        toast.error(response.data.message || "Failed to add candidate.");
      }
    } catch (error) {
      console.error("Error adding candidate:", error);
      toast.error("❌ Failed to add candidate.");
    } finally {
      setAddingCandidate(false);
      setActionLoading(false);
    }
  };

  return (
    <>
      {actionLoading && (
        <div
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: "rgba(255, 255, 255, 0.7)",
            zIndex: 9999,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            flexDirection: "column",
          }}
        >
          <Spinner animation="border" variant="primary" />
          <div className="mt-2">Processing, please wait...</div>
        </div>
      )}
      <Container fluid className="my-4">
        <h2>Campaign Details: {campaignId}</h2>

        {/* Actions */}
        <div className="d-flex gap-2 my-3">
          <Button
            variant="secondary"
            disabled={actionLoading || isCompleted}
            onClick={handleDownloadJD}
          >
            Download JDs
          </Button>
          {isHR && (
            <>
              <Button
                variant="success"
                disabled={actionLoading || isCompleted}
                onClick={handleCompleteCampaign}
              >
                Mark Campaign as Complete
              </Button>
              <Button
                variant="primary"
                disabled={actionLoading || isCompleted}
                onClick={() => setShowAddCandidate(!showAddCandidate)}
              >
                {showAddCandidate ? "Cancel Add Candidate" : "Add Candidate"}
              </Button>
            </>
          )}

          {isCompleted && (
            <Button
              variant="warning"
              disabled={actionLoading}
              onClick={async () => {
                if (
                  !window.confirm(
                    "Are you sure you want to reopen this campaign?"
                  )
                )
                  return;
                setActionLoading(true);
                try {
                  await axiosInstance.post(`/campaign/${campaignId}/reopen`);
                  toast.success("✅ Campaign reopened successfully!");
                  fetchCampaignStatus();
                } catch (error) {
                  console.error("Error reopening campaign:", error);
                  toast.error("❌ Failed to reopen campaign.");
                } finally {
                  setActionLoading(false);
                }
              }}
            >
              Reopen Campaign
            </Button>
          )}
        </div>

        {showAddCandidate && (
          <div className="mb-3">
            <Row className="align-items-end g-2">
              <Col md={3}>
                <Form.Control
                  placeholder="Full Name"
                  value={newCandidateName}
                  onChange={(e) => setNewCandidateName(e.target.value)}
                />
              </Col>
              <Col md={3}>
                <Form.Control
                  placeholder="Email"
                  value={newCandidateEmail}
                  onChange={(e) => setNewCandidateEmail(e.target.value)}
                />
              </Col>
              <Col md={2}>
                <Form.Control
                  placeholder="Phone"
                  value={newCandidatePhone}
                  onChange={(e) => {
                    const value = e.target.value;
                    if (/^\d*$/.test(value) && value.length <= 10) {
                      setNewCandidatePhone(value);
                    }
                  }}
                />
              </Col>
              <Col md={3}>
                <Form.Control
                  type="file"
                  accept=".pdf,application/pdf"
                  onChange={(e) => {
                    const files = (e.target as HTMLInputElement).files;
                    const file = files && files[0];
                    if (file) {
                      if (file.type !== "application/pdf") {
                        toast.error("❌ Only PDF files are allowed.");
                        e.target.value = ""; // clear the input
                        return;
                      }
                      if (file.size > 10 * 1024 * 1024) {
                        toast.error("❌ File size should not exceed 10 MB.");
                        e.target.value = ""; // clear the input
                        return;
                      }
                      setNewCandidateResume(file);
                    }
                  }}
                />
              </Col>
              <Col md={1}>
                <Button
                  variant="success"
                  onClick={handleAddCandidate}
                  disabled={actionLoading || isCompleted}
                >
                  {addingCandidate ? (
                    <Spinner size="sm" animation="border" />
                  ) : (
                    "Add"
                  )}
                </Button>
              </Col>
            </Row>
          </div>
        )}

        {/* Assign Roles */}
        {isHR && (
          <div className="d-flex gap-2 mb-3">
            <Button
              variant="outline-primary"
              disabled={actionLoading || isCompleted}
              onClick={() => setShowL2Input(!showL2Input)}
            >
              {showL2Input ? "Cancel L2" : "Assign L2"}
            </Button>
            <Button
              variant="outline-primary"
              disabled={actionLoading || isCompleted}
              onClick={() => setShowL3Input(!showL3Input)}
            >
              {showL3Input ? "Cancel L3" : "Assign L3"}
            </Button>
            <Button
              variant="outline-primary"
              disabled={actionLoading || isCompleted}
              onClick={() => setShowL1Input(!showL1Input)}
            >
              {showL1Input ? "Cancel L1" : "Assign L1"}
            </Button>
            <Button
              variant="outline-primary"
              disabled={actionLoading || isCompleted}
              onClick={() => setShowHRInput(!showHRInput)}
            >
              {showHRInput ? "Cancel HR" : "Assign HR"}
            </Button>
          </div>
        )}

        {/* L2 Input */}
        {showL2Input && (
          <div className="mb-3 d-flex gap-2">
            <Form.Control
              placeholder="Enter L2 Email"
              value={newL2}
              onChange={(e) => setNewL2(e.target.value)}
              style={{ maxWidth: "300px" }}
            />
            <Button
              variant="success"
              disabled={actionLoading || isCompleted}
              onClick={() => handleAddRole("l2")}
            >
              Add L2
            </Button>
          </div>
        )}

        {/* L3 Input */}
        {showL3Input && (
          <div className="mb-3 d-flex gap-2">
            <Form.Control
              placeholder="Enter L3 Email"
              value={newL3}
              onChange={(e) => setNewL3(e.target.value)}
              style={{ maxWidth: "300px" }}
            />
            <Button
              variant="success"
              disabled={actionLoading || isCompleted}
              onClick={() => handleAddRole("l3")}
            >
              Add L3
            </Button>
          </div>
        )}

        {/* L1 Input */}
        {showL1Input && (
          <div className="mb-3 d-flex gap-2">
            <Form.Control
              placeholder="Enter L1 Email"
              value={newL1}
              onChange={(e) => setNewL1(e.target.value)}
              style={{ maxWidth: "300px" }}
            />
            <Button
              variant="success"
              disabled={actionLoading || isCompleted}
              onClick={() => handleAddRole("l1")}
            >
              Add L1
            </Button>
          </div>
        )}

        {/* HR Input */}
        {showHRInput && (
          <div className="mb-3 d-flex gap-2">
            <Form.Control
              placeholder="Enter HR Email"
              value={newHR}
              onChange={(e) => setNewHR(e.target.value)}
              style={{ maxWidth: "300px" }}
            />
            <Button
              variant="success"
              disabled={actionLoading || isCompleted}
              onClick={() => handleAddRole("hr")}
            >
              Add HR
            </Button>
          </div>
        )}

        {/* Filters */}
        <Row className="mb-3">
          <Col md={3}>
            <Form.Control
              placeholder="Filter by Name"
              value={filterName}
              onChange={(e) => setFilterName(e.target.value)}
            />
          </Col>
          <Col md={3}>
            <Form.Control
              placeholder="Filter by Email"
              value={filterEmail}
              onChange={(e) => setFilterEmail(e.target.value)}
            />
          </Col>
          <Col md={3}>
            <Form.Control
              placeholder="Filter by Phone"
              value={filterPhone}
              onChange={(e) => {
                const value = e.target.value;
                if (/^\d*$/.test(value) && value.length <= 10) {
                  setFilterPhone(value);
                }
              }}
            />
          </Col>
          <Col md={2}>
            <Form.Select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
            >
              {statuses.map((status) => (
                <option key={status} value={status}>
                  {status}
                </option>
              ))}
            </Form.Select>
          </Col>
          <Col md={1}>
            <Button
              variant="outline-secondary"
              disabled={actionLoading || isCompleted}
              onClick={resetFilters}
            >
              Reset
            </Button>
          </Col>
        </Row>

        {loading ? (
          <div className="text-center">
            <Spinner animation="border" />
          </div>
        ) : (
          <>
            {/* Table */}
            <div style={{ overflowX: "auto" }}>
              <Table bordered hover responsive>
                <thead className="table-light">
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>App Status</th>
                    <th>L1 Status</th>
                    <th>L1 Feedback</th>
                    <th>L2 Status</th>
                    <th>L2 Feedback</th>
                    <th>L3 Status</th>
                    <th>L3 Feedback</th>
                    <th>HR Status</th>
                    <th>HR Feedback</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {currentCandidates.map((candidate) => {
                    const rowDisabled =
                      candidate.app_status === "Completed" && userRole !== "HR";
                    return (
                      <tr key={candidate.candidate_id}>
                        <td>{candidate.full_name}</td>
                        <td>{candidate.email_id}</td>
                        <td>{candidate.phone}</td>
                        <td>
                          <Badge
                            bg={
                              candidate.app_status === "Completed"
                                ? "success"
                                : candidate.app_status === "Rejected"
                                ? "danger"
                                : "info"
                            }
                          >
                            {candidate.app_status}
                          </Badge>
                        </td>

                        {[
                          "l1_status",
                          "l1_feedback",
                          "l2_status",
                          "l2_feedback",
                          "l3_status",
                          "l3_feedback",
                          "hr_status",
                          "hr_feedback",
                        ].map((field) => {
                          const isHRField = field.startsWith("hr_");
                          const isAppCompletedOrRejected = [
                            "Completed",
                            "Rejected",
                          ].includes(candidate.app_status);
                          const shouldDisable =
                            isCompleted ||
                            rowDisabled ||
                            (isHRField && !isHR) ||
                            (isAppCompletedOrRejected && !isHR);

                          return field.includes("status") ? (
                            <td key={field}>
                              {shouldDisable ? (
                                <span>
                                  {
                                    candidate[
                                      field as keyof Candidate
                                    ] as string
                                  }
                                </span>
                              ) : (
                                <Form.Select
                                  size="sm"
                                  value={
                                    (editedStatus[candidate.candidate_id]?.[
                                      field as keyof Candidate
                                    ] as string) ??
                                    (candidate[
                                      field as keyof Candidate
                                    ] as string)
                                  }
                                  onChange={(e) =>
                                    setEditedStatus((prev) => ({
                                      ...prev,
                                      [candidate.candidate_id]: {
                                        ...prev[candidate.candidate_id],
                                        [field]: e.target.value,
                                      },
                                    }))
                                  }
                                >
                                  {statuses.slice(1).map((status) => (
                                    <option key={status} value={status}>
                                      {status}
                                    </option>
                                  ))}
                                </Form.Select>
                              )}
                            </td>
                          ) : (
                            <td key={field}>
                              {shouldDisable ? (
                                <span>
                                  {
                                    candidate[
                                      field as keyof Candidate
                                    ] as string
                                  }
                                </span>
                              ) : (
                                <Form.Control
                                  size="sm"
                                  value={
                                    (editedStatus[candidate.candidate_id]?.[
                                      field as keyof Candidate
                                    ] as string) ??
                                    (candidate[
                                      field as keyof Candidate
                                    ] as string)
                                  }
                                  onChange={(e) =>
                                    setEditedStatus((prev) => ({
                                      ...prev,
                                      [candidate.candidate_id]: {
                                        ...prev[candidate.candidate_id],
                                        [field]: e.target.value,
                                      },
                                    }))
                                  }
                                />
                              )}
                            </td>
                          );
                        })}
                        <td>
                          <div className="d-flex flex-column gap-1">
                            <Button
                              size="sm"
                              variant="success"
                              disabled={
                                actionLoading ||
                                isCompleted ||
                                (candidate.app_status === "Completed" &&
                                  userRole !== "HR")
                              }
                              onClick={async () => {
                                const updates =
                                  editedStatus[candidate.candidate_id];
                                if (!updates) {
                                  toast("No changes to update.");
                                  return;
                                }
                                setActionLoading(true);
                                try {
                                  await axiosInstance.post(
                                    `/campaign/${campaignId}/candidate/${candidate.candidate_id}/status`,
                                    { updates, userRole }
                                  );
                                  toast.success("✅ Status/feedback updated!");
                                  setEditedStatus((prev) => {
                                    const newState = { ...prev };
                                    delete newState[candidate.candidate_id];
                                    return newState;
                                  });
                                  fetchCandidates(); // refresh the data
                                } catch (error) {
                                  console.error(error);
                                  toast.error(
                                    "❌ Failed to update status/feedback."
                                  );
                                } finally {
                                  setActionLoading(false);
                                }
                              }}
                            >
                              Update Status
                            </Button>
                            <Button
                              size="sm"
                              variant="info"
                              disabled={actionLoading || isCompleted}
                              onClick={() =>
                                handleDownloadResume(candidate.candidate_id)
                              }
                            >
                              Download Resume
                            </Button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </Table>
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <Pagination className="justify-content-center mt-3">
                <Pagination.First
                  onClick={() => setCurrentPage(1)}
                  disabled={currentPage === 1}
                />
                <Pagination.Prev
                  onClick={() =>
                    setCurrentPage((prev) => Math.max(prev - 1, 1))
                  }
                  disabled={currentPage === 1}
                />
                {Array.from({ length: totalPages }, (_, idx) => (
                  <Pagination.Item
                    key={idx + 1}
                    active={idx + 1 === currentPage}
                    onClick={() => setCurrentPage(idx + 1)}
                  >
                    {idx + 1}
                  </Pagination.Item>
                ))}
                <Pagination.Next
                  onClick={() =>
                    setCurrentPage((prev) => Math.min(prev + 1, totalPages))
                  }
                  disabled={currentPage === totalPages}
                />
                <Pagination.Last
                  onClick={() => setCurrentPage(totalPages)}
                  disabled={currentPage === totalPages}
                />
              </Pagination>
            )}

            {currentCandidates.length === 0 && !loading && (
              <div className="text-center my-5">
                <img
                  src="https://cdn-icons-png.flaticon.com/512/4076/4076549.png"
                  alt="No Data"
                  width={100}
                  className="mb-3"
                />
                <h5>No candidates found</h5>
                <p className="text-muted">
                  Try adjusting filters or add new candidates to this campaign.
                </p>
              </div>
            )}

            {/* Charts */}
            <Row className="mt-4">
              <Col md={6}>
                <Card>
                  <Card.Body>
                    <h5>Audit Trail (Pie Chart)</h5>
                    <Pie data={pieData} />
                  </Card.Body>
                </Card>
              </Col>
              <Col md={6}>
                <Card>
                  <Card.Body>
                    <h5>Campaign Status Overview (Bar Chart)</h5>
                    <Bar data={barData} />
                  </Card.Body>
                </Card>
              </Col>
            </Row>
          </>
        )}
      </Container>
    </>
  );
};

export default CampaignDetailPage;
