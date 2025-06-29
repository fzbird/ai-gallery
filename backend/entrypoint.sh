#!/bin/sh

# Go to the app directory
cd /app

# Wait for the database to be ready
# (This is a simple version, a more robust solution might use docker-compose healthchecks or wait-for-it.sh)
sleep 10 

# Run database migrations
alembic upgrade head

# Start the application
uvicorn app.main:app --host 0.0.0.0 --port 8000 