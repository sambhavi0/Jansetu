FROM python:3.11-slim

# ffmpeg is required by openai-whisper to actually decode audio.
# Render's native Python runtime has no apt access, so we need this Dockerfile.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Render sets $PORT at runtime and expects the app to bind to 0.0.0.0
CMD uvicorn main:app --host 0.0.0.0 --port $PORT