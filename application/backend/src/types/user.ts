export interface User {
  full_name: string | null;
  email: string;
  phone: number | null;
  experience: number | null;
  band: string | null;
  skill: string | null;
  password: string;
  role: "HR" | "Manager" | "L1";
}
