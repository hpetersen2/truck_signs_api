#!/usr/bin/env bash
set -e

# Warten auf PostgreSQL
HOST="${DATABASE_HOST:-db}"
PORT="${DATABASE_PORT:-5432}"

echo "Waiting for postgres at ${HOST}:${PORT} ..."
while ! nc -z "${HOST}" "${PORT}"; do
  sleep 0.1
done
echo "PostgreSQL is active"

python manage.py migrate
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