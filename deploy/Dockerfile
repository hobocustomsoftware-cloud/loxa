# syntax=docker/dockerfile:1.6
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# If you use requirements.txt
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Or if you use pyproject.toml (Poetry), copy & install instead.
# COPY pyproject.toml poetry.lock* ./
# RUN pip install --no-cache-dir poetry && poetry config virtualenvs.create false \
#     && poetry install --no-interaction --no-ansi

# Copy project
COPY . .

EXPOSE 8000


RUN pip install --no-cache-dir psycopg2-binary==2.9.10
