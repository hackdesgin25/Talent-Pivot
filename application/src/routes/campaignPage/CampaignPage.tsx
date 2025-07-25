/* eslint-disable @typescript-eslint/no-explicit-any */
import { useEffect, useState } from "react";
import {
  Container,
  Row,
  Col,
  Card,
  Button,
  Badge,
  Form,
  Spinner,
} from "react-bootstrap";
import { useNavigate } from "react-router-dom";
import Cookies from "js-cookie";
import axiosInstance from "../../api/axiosInstance";
import toast from "react-hot-toast";

type Campaign = {
  campaign_status: string;
  campaign_id: string;
  campaign_name: string;
  note: string;
  status: string;
};

const CampaignPage = () => {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [isHR, setIsHR] = useState(false);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchCampaigns = async () => {
      try {
        setLoading(true);
        const response = await axiosInstance.get("/campaign");

        if (response.data.success) {
          const fetchedCampaigns = response.data.data;
          console.log(fetchedCampaigns);
          fetchedCampaigns.sort((a: any, b: any) => {
            console.log(a, "a");
            if (a.campaign_status === b.campaign_status) return 0;
            return a.campaign_status === "Active" ? -1 : 1;
          });

          setCampaigns(fetchedCampaigns);
        } else {
          toast.error(response.data.message || "Failed to fetch campaigns.");
        }
      } catch (error: any) {
        console.error("❌ Error fetching campaigns:", error);
        toast.error(
          error?.response?.data?.message ||
            "Failed to fetch campaigns. Please try again."
        );
      } finally {
        setLoading(false);
      }
    };

    fetchCampaigns();

    const userRole = Cookies.get("role")?.toUpperCase();
    setIsHR(userRole === "HR");
  }, []);

  const handleCreateCampaign = () => {
    navigate("/create-campaign");
  };

  const handleCardClick = (id: string) => {
    navigate(`/campaigns/${id}`);
  };

  const filteredCampaigns = campaigns.filter((campaign) =>
    campaign.campaign_name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Container className="py-4 position-relative">
      {loading && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100 d-flex justify-content-center align-items-center bg-light bg-opacity-75"
          style={{ zIndex: 9999 }}
        >
          <Spinner animation="border" role="status" variant="primary" />
        </div>
      )}

      <Row className="align-items-center mb-4">
        <Col xs={12} md={6}>
          <h2>Campaigns</h2>
        </Col>
        {isHR && (
          <Col xs={12} md={3} className="text-md-end mt-2 mt-md-0">
            <Button variant="primary" onClick={handleCreateCampaign}>
              Create Campaign
            </Button>
          </Col>
        )}
        <Col xs={12} md={3} className="my-2 my-md-0">
          <Form.Control
            type="text"
            placeholder="Search campaigns..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </Col>
      </Row>

      <Row xs={1} sm={2} md={3} lg={4} className="g-4">
        {filteredCampaigns.map((campaign) => (
          <Col key={campaign.campaign_id}>
            <Card
              onClick={() => handleCardClick(campaign.campaign_id)}
              className="h-100 shadow-sm campaign-card-hover"
              style={{ cursor: "pointer", transition: "transform 0.2s" }}
            >
              <Card.Body>
                <Card.Title className="mb-2">
                  {campaign.campaign_name}
                </Card.Title>
                <Card.Text
                  className="text-muted mb-3"
                  style={{ minHeight: "60px" }}
                >
                  {campaign.note}
                </Card.Text>
                <Badge
                  bg={
                    campaign.campaign_status === "Active"
                      ? "success"
                      : "secondary"
                  }
                >
                  {campaign.campaign_status}
                </Badge>
              </Card.Body>
            </Card>
          </Col>
        ))}
      </Row>
    </Container>
  );
};

export default CampaignPage;
