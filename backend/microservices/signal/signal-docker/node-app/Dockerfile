# Dockerfile for a simple Node.js application
# Use the official Node.js image as a base

FROM node:18
# Set the working directory in the container
# This is where the application code will be copied
# and where commands will be run
WORKDIR /app
# Copy package.json and package-lock.json
# to the working directory
# This is done to install dependencies before copying the rest of the code
COPY package.json package-lock.json ./
RUN npm install

COPY . .
# Expose the port the app runs on
# This is the port that the application will listen on
# and the port that will be mapped to the host
EXPOSE 3000
CMD ["node", "index.js"]
