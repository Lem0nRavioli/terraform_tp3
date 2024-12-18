# Use the official Python base image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire repo into the container
COPY . .

# Expose the MLflow UI and model serving ports
EXPOSE 5000 1234

# Set environment variables for MLflow tracking (optional)
ENV MLFLOW_TRACKING_URI=http://0.0.0.0:5000

# Define the entrypoint script for running MLflow
ENTRYPOINT ["mlflow"]

# Command to execute the script
ENTRYPOINT ["python", "entrypoint.py"]