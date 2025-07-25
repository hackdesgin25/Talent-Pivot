// Extend Express Request interface for custom properties
declare global {
  namespace Express {
    interface UserPayload {
      email: string;
      role: string;
    }

    interface Request {
      user?: UserPayload;
    }
  }
}

export {};

import { JwtPayload } from "jsonwebtoken";

declare namespace Express {
  export interface Request {
    user?: string | JwtPayload;
  }
}
