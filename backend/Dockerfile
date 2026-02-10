FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       git \
       libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Copy data directories into the image
COPY data ./data
COPY dbt_project ./dbt_project

ENV DBT_ARTIFACTS_PATH=/app/data/artifacts
ENV DBT_PROJECT_PATH=/app/data/repos/default
ENV DBT_PROFILES_PATH=/app/data/profiles
ENV BACKEND_PORT=8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
