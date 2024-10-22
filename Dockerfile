# Use an official Node.js runtime as a parent image
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json from the current directory
COPY package.json package-lock.json ./

# Install dependencies inside the container
RUN npm install

# Copy the rest of the application source code to the container
COPY . .

# Expose the port on which the app will run
EXPOSE 3000

# Command to run the app
CMD ["node", "app.js"]
