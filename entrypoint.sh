#!/usr/bin/env bash
set -e

# .env für Django erzeugen aus den Container-Umgebungsvariablen
ENV_FILE="/app/truck_signs_designs/settings/simple_env_config.env"

cat > "${ENV_FILE}" <<EOF
SECRET_KEY=${SECRET_KEY}
DOCKER_SECRET_KEY=${SECRET_KEY}

DOCKER_DB_NAME=${DATABASE_NAME}
DOCKER_DB_USER=${DATABASE_USERNAME}
DOCKER_DB_PASSWORD=${DATABASE_PASSWORD}
DOCKER_DB_HOST=${DATABASE_HOST}
DOCKER_DB_PORT=${DATABASE_PORT}

DATABASE_ENGINE=${DATABASE_ENGINE}
DATABASE_NAME=${DATABASE_NAME}
DATABASE_USERNAME=${DATABASE_USERNAME}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
DATABASE_HOST=${DATABASE_HOST}
DATABASE_PORT=${DATABASE_PORT}

DEBUG=${DEBUG:-False}
DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS:-localhost,127.0.0.1}
DJANGO_LOGLEVEL=${DJANGO_LOGLEVEL:-info}
EOF

# Warten auf PostgreSQL
HOST="${DATABASE_HOST:-db}"
PORT="${DATABASE_PORT:-5432}"

echo "Waiting for postgres at ${HOST}:${PORT} ..."
while ! nc -z "${HOST}" "${PORT}"; do
  sleep 0.1
done
echo "PostgreSQL is active"

python manage.py migrate
python manage.py makemigrations
python manage.py collectstatic --noinput

# Superuser anlegen (nur wenn nicht vorhanden)
python manage.py shell <<PYEOF
import os
from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ.get('DJANGO_SUPERUSER_USERNAME')
email    = os.environ.get('DJANGO_SUPERUSER_EMAIL', '')
password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')

if not username or not password:
    raise ValueError("DJANGO_SUPERUSER_USERNAME and DJANGO_SUPERUSER_PASSWORD must be set")

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
    print(f"Superuser '{username}' created.")
else:
    print(f"Superuser '{username}' already exists, skipping.")
PYEOF

exec gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:8020