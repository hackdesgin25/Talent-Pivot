import express from "express";
import { loginUser, registerUser } from "../controllers/authController";
import {
  addCandidateToCampaign,
  assignRoleToCampaign,
  completeCampaign,
  createCampaign,
  getCampaignCandidates,
  getCampaignJDUrls,
  getCandidateResumeUrl,
  getMyCampaigns,
  openCampaign,
  statusCampaign,
  updateCandidateStatus,
} from "../controllers/campaignController";
import upload, { uploadResume } from "../middleware/upload";
import authMiddleware from "../middleware/authMiddleware";

const router = express.Router();

// POST /api/v1/register
router.post("/register", registerUser);
router.post("/login", loginUser);
router.post("/campaign", authMiddleware, upload, createCampaign);
router.get("/campaign", authMiddleware, getMyCampaigns);
router.post(
  "/campaign/:campaignId/add-candidate",
  authMiddleware,
  uploadResume,
  addCandidateToCampaign
);
router.get(
  "/campaign/:campaignId/candidates",
  authMiddleware,
  getCampaignCandidates
);
router.get("/campaign/:campaignId/status", authMiddleware, statusCampaign);
router.post(
  "/campaign/:campaignId/candidate/:candidateId/status",
  authMiddleware,
  updateCandidateStatus
);
router.get(
  "/campaign/:campaignId/candidate/:candidateId/resume",
  authMiddleware,
  getCandidateResumeUrl
);
router.get("/campaign/:campaignId/jds", authMiddleware, getCampaignJDUrls);
router.post("/campaign/:campaignId/complete", authMiddleware, completeCampaign);
router.post("/campaign/:campaignId/reopen", authMiddleware, openCampaign);

router.post(
  "/campaign/:campaignId/assign-role",
  authMiddleware,
  assignRoleToCampaign
);

export default router;
