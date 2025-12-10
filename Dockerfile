FROM python:3.13.3-slim

# Install system dependencies including audio libraries
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    cmake \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install poetry
RUN pip install poetry==2.1.2

# Configure poetry to not create a virtual environment globally
RUN poetry config virtualenvs.create false

# Copy application code
COPY . .

# Install dependencies
RUN poetry install

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create non-root user for security
RUN adduser --disabled-password --gecos "" appuser

# Change ownership of the app directory to appuser
RUN chown -R appuser:appuser /app
RUN mkdir -p /temp/files /temp/insurance
RUN chown -R appuser:appuser /temp

# Switch to appuser and configure poetry for this user
USER appuser
RUN poetry config virtualenvs.create false

# Expose port
# EXPOSE $PORT

# Start the application
CMD uvicorn app.main:app --host 0.0.0.0 --port 4002
