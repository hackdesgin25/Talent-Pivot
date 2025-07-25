# Backend Dockerfile for Node.js/Express API (Cloud Run ready)

FROM node:20-alpine

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build TypeScript to JavaScript
RUN npm run build

EXPOSE 8080

# Start the server
CMD ["npm", "start"]
