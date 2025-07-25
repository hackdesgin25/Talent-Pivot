import Multer from "multer";

const upload = Multer({
  storage: Multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
}).array("jdFiles", 10);

export const uploadResume = Multer({
  storage: Multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
}).single("resume"); // expects single file with field name 'resume'

export default upload;
