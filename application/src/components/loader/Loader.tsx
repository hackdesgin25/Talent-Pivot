// src/components/loader/Loader.tsx
import { Spinner } from "react-bootstrap";

const Loader = () => {
  return (
    <div className="d-flex flex-column justify-content-center align-items-center vh-100 vw-100 bg-light position-fixed top-0 start-0 z-3">
      <Spinner
        animation="border"
        role="status"
        variant="primary"
        style={{ width: "4rem", height: "4rem" }}
      >
        <span className="visually-hidden">Loading...</span>
      </Spinner>
      <div className="mt-3 text-primary fs-5">Loading...</div>
    </div>
  );
};

export default Loader;
