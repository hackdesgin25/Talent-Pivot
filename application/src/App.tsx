import { BrowserRouter, Route, Routes } from "react-router";
import "./App.css";

import Login from "./routes/login/Login";
import UpdatePassword from "./routes/updatePassword/UpdatePassword";
import { Suspense } from "react";

import Register from "./routes/register/Register";
import NotFound from "./routes/notFound/NotFound";
import Loader from "./components/loader/Loader";
import Navbar from "./components/navBar/NavBar";
import CampaignPage from "./routes/campaignPage/CampaignPage";
import CampaignDetailPage from "./routes/campaignDetailPage/CampaignDetailPage";
import RequireAuth from "./components/requireAuth/RequireAuth";
import CreateCampaignPage from "./routes/createCampaignPage/CreateCampaignPage";
import CreateCampaignSummary from "./routes/createCampaignSummary/CreateCampaignSummary";
import CreateCampaignSuccess from "./routes/createCampaignSuccess/CreateCampaignSuccess";

function App() {
  return (
    <Suspense fallback={<Loader />}>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="/register" element={<Register />} />

          <Route
            path="/updatePassword"
            element={
              <RequireAuth>
                <UpdatePassword />
              </RequireAuth>
            }
          />

          <Route
            path="/campaigns"
            element={
              <RequireAuth>
                <CampaignPage />
              </RequireAuth>
            }
          />

          <Route
            path="/campaigns/:id"
            element={
              <RequireAuth>
                <CampaignDetailPage />
              </RequireAuth>
            }
          />

          <Route
            path="/create-campaign"
            element={
              <RequireAuth>
                <CreateCampaignPage />
              </RequireAuth>
            }
          />
          <Route
            path="/create-campaign/summary"
            element={
              <RequireAuth>
                <CreateCampaignSummary />
              </RequireAuth>
            }
          />
          <Route
            path="/create-campaign/success"
            element={
              <RequireAuth>
                <CreateCampaignSuccess />
              </RequireAuth>
            }
          />

          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </Suspense>
  );
}

export default App;
