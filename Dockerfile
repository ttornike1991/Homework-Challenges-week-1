# Use the official Node.js 14 image as the base image
FROM node:14-alpine

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install the dependencies and remove the cache
RUN apk update && \
    apk upgrade && \
    npm ci --only=production && \
    rm -rf /var/cache/apk/*

# Copy the rest of the application files to the container
COPY . .

# Copy the start.sh script to the container
COPY start.sh /app/

# Make the start.sh script executable
RUN chmod +x /app/start.sh

# Set the user to non-root
USER node

# Run the start.sh script as the CMD
CMD ["/bin/sh", "/app/start.sh"]
