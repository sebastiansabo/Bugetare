FROM python:3.11-slim

# Install poppler for PDF processing
RUN apt-get update && apt-get install -y \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Copy application code
COPY app/ ./app/

# Create directories
RUN mkdir -p Invoices

WORKDIR /app/app

# Expose port
EXPOSE 8080

# Run with gunicorn (2 workers + 2 threads each)
# Keep workers low due to DigitalOcean DB connection limits (~25 max)
# Timeout settings prevent worker hangs after idle periods:
#   --timeout: Kill worker if no response in 120s
#   --graceful-timeout: Allow 30s for graceful shutdown
#   --keep-alive: Keep HTTP connections open for 5s (reduces reconnects)
# Worker recycling prevents memory accumulation:
#   --max-requests: Recycle worker after N requests
#   --max-requests-jitter: Stagger recycling to avoid simultaneous restarts
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "2", "--worker-class", "gthread", "--timeout", "120", "--graceful-timeout", "30", "--keep-alive", "5", "--max-requests", "500", "--max-requests-jitter", "50", "app:app"]
