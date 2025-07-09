# --- Base Image ---
FROM python:3.9-bullseye

# --- Set Working Directory ---
WORKDIR /app

# --- Install Dependencies ---
# Copy requirements first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt
RUN pip install --upgrade pip -i https://mirrors.cloud.tencent.com/pypi/simple --trusted-host mirrors.cloud.tencent.com
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple --trusted-host mirrors.cloud.tencent.com

# Copy scripts and fix permissions for Linux
COPY ./entrypoint.sh /app/entrypoint.sh
COPY ./startup.sh /app/startup.sh

# Fix line endings and permissions for Linux compatibility
# Also create a backup with correct permissions
RUN sed -i 's/\r$//' /app/entrypoint.sh && \
    sed -i 's/\r$//' /app/startup.sh && \
    chmod +x /app/entrypoint.sh && \
    chmod +x /app/startup.sh && \
    cp /app/entrypoint.sh /app/entrypoint_backup.sh && \
    chmod +x /app/entrypoint_backup.sh && \
    ls -la /app/entrypoint.sh /app/startup.sh

# --- Copy Application Code ---
COPY ./app /app/app

# --- Run Application ---
# Use startup.sh as entrypoint to ensure permissions
ENTRYPOINT ["/app/startup.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
