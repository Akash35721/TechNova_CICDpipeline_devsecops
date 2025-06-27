



# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# --- THIS IS THE ONLY CHANGE ---
# Copy the templates and the new static folder into the container
COPY templates/ ./templates/
COPY static/ ./static/

# Copy the main application file
COPY app.py .

# Command to run the application
CMD ["python", "app.py"]