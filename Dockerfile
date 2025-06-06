# ---- Builder Stage ----
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
# Install all dependencies (including dev) to run the build
RUN npm ci
COPY . .
# Build the application
RUN npm run build

# ---- Production Stage ----
FROM node:20-slim AS production
# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# Copy compiled code and package files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
# Install ONLY production dependencies for a lean image
RUN npm ci --omit=dev
ENV NODE_ENV=production
EXPOSE 3001
CMD ["node", "dist/main.js"] 