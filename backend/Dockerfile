# --- Base Image ---
FROM python:3.9-bullseye

# --- Set Working Directory ---
WORKDIR /app

# --- Install Dependencies ---
# Copy requirements first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt
RUN pip install --upgrade pip -i https://mirrors.cloud.tencent.com/pypi/simple --trusted-host mirrors.cloud.tencent.com
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple --trusted-host mirrors.cloud.tencent.com

# Copy entrypoint script and fix permissions for Linux
COPY ./entrypoint.sh /app/entrypoint.sh

# Fix line endings and permissions for Linux compatibility
# Also create a backup with correct permissions
RUN sed -i 's/\r$//' /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh && \
    cp /app/entrypoint.sh /app/entrypoint_backup.sh && \
    chmod +x /app/entrypoint_backup.sh && \
    ls -la /app/entrypoint.sh

# --- Copy Application Code ---
COPY ./app /app/app

# Create a startup script that ensures permissions are correct
RUN echo '#!/bin/bash' > /app/startup.sh && \
    echo 'chmod +x /app/entrypoint.sh 2>/dev/null || true' >> /app/startup.sh && \
    echo 'if [ ! -x /app/entrypoint.sh ]; then' >> /app/startup.sh && \
    echo '  echo "修复 entrypoint.sh 权限..."' >> /app/startup.sh && \
    echo '  cp /app/entrypoint_backup.sh /app/entrypoint.sh' >> /app/startup.sh && \
    echo '  chmod +x /app/entrypoint.sh' >> /app/startup.sh && \
    echo 'fi' >> /app/startup.sh && \
    echo 'exec /app/entrypoint.sh "$@"' >> /app/startup.sh && \
    chmod +x /app/startup.sh

# --- Run Application ---
# Use startup.sh as entrypoint to ensure permissions
ENTRYPOINT ["/app/startup.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
