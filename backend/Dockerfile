# --- Base Image ---
FROM python:3.9-bullseye

# --- Set Working Directory ---
WORKDIR /app

# --- Install Dependencies ---
# Copy requirements first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple --trusted-host pypi.tuna.tsinghua.edu.cn

# Copy entrypoint script
COPY ./entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# --- Copy Application Code ---
COPY ./app /app/app

# --- Run Application ---
# The command will be overridden by docker-compose
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
