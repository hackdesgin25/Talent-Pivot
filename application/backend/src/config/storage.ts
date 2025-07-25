import { Storage } from "@google-cloud/storage";
import path from "path";
const keyPath = path.resolve(
  process.cwd(),
  process.env.GOOGLE_APPLICATION_CREDENTIALS || ""
);

const storage = new Storage({
  projectId: process.env.GCLOUD_PROJECT_ID,
  keyFilename: keyPath,
});

const bucket = storage.bucket(process.env.GCP_BUCKET || "");

export default bucket;
