# Builder-Stage: Installation der Abhängigkeiten
FROM python:3.6-slim AS builder

RUN mkdir /app

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1 

RUN pip install --upgrade pip
RUN apt-get update && apt-get install -y \
    gcc \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Kopiere requirements.txt und installiere die Abhängigkeiten
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Laufzeit-Stage
FROM python:3.6-slim

RUN apt-get update && apt-get install -y \
    postgresql-client \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

# Erstelle den User und das App-Verzeichnis
RUN useradd -m -r appuser && \
    mkdir /app && \
    chown -R appuser /app

# Kopiere die Abhängigkeiten aus der Builder-Phase
COPY --from=builder /usr/local/lib/python3.6/site-packages/ /usr/local/lib/python3.6/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY entrypoint.sh /app/entrypoint.sh

# Setze das Arbeitsverzeichnis
WORKDIR /app

# Kopiere alle notwendigen Dateien (und setze den Besitzer)
COPY --chown=appuser:appuser . .

# Stelle sicher, dass das Entry-Script ausführbar ist
RUN chmod +x entrypoint.sh

# Setze Umgebungsvariablen
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Setze den Benutzer, der die Anwendung ausführt
USER appuser

# Exponiere den Port 8020
EXPOSE 8020

# Setze das Entry-Point-Skript
ENTRYPOINT ["./entrypoint.sh"]