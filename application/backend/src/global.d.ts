declare class AggregateError extends Error {
  errors: unknown[];
  constructor(errors: unknown[], message?: string);
}

interface ErrorOptions {
  cause?: unknown;
}

import { DecodedToken } from "./types/decodedToken"; // adjust path as per your structure

declare global {
  namespace Express {
    interface Request {
      user?: DecodedToken;
    }
  }
}
