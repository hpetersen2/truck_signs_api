# Builder-Stage: Installation der Abhängigkeiten
FROM python:3.8-slim AS builder

RUN mkdir /app
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip
RUN apt-get update && apt-get install -y \
    gcc \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt


# Laufzeit-Stage
FROM python:3.8-slim

RUN apt-get update && apt-get install -y \
    postgresql-client \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -r appuser && \
    mkdir /app && \
    chown -R appuser /app

COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

COPY entrypoint.sh /app/entrypoint.sh

WORKDIR /app

COPY --chown=appuser:appuser . .

RUN chmod +x /app/entrypoint.sh

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser

EXPOSE 8020

ENTRYPOINT ["/app/entrypoint.sh"]