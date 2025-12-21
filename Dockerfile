# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Sync SvelteKit (required before build)
RUN npm run prepare

# Build the application
# SvelteKit with adapter-static outputs to build/ directory
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built assets
# SvelteKit with adapter-static outputs to build/ directory
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx config for SPA routing
RUN echo 'server { \
    listen 3000; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]

