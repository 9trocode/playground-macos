# Use the official Node.js 18 image as a builder stage
FROM node:18-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml files
COPY package.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of your app's source code from your host to your image filesystem.
COPY . .

# Build the project (assumes a ViteJS project)
RUN pnpm run build

# Use nginx alpine for a smaller production image
FROM nginx:1.21-alpine

# Copy the built assets from the builder stage to the nginx server
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 to the outside once the container has launched
EXPOSE 80

# Start nginx with global directives and daemon off
CMD ["nginx", "-g", "daemon off;"]
