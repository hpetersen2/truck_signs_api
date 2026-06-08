#!/usr/bin/env bash
set -e

echo "Waiting for postgres to connect ..."

HOST=${DATABASE_HOST:-db}
PORT=${DATABASE_PORT:-5432}

while ! nc -z "$HOST" "$PORT"; do
  sleep 0.1
done

echo "PostgreSQL is active"

python manage.py collectstatic --noinput
python manage.py migrate
python manage.py makemigrations

python manage.py shell <<EOF
import os
from django.contrib.auth import get_user_model

User = get_user_model()

username = os.environ.get('DOCKER_DJANGO_SUPERUSER_USERNAME', 'admin')
email = os.environ.get('DOCKER_DJANGO_SUPERUSER_EMAIL', 'admin@example.com')
password = os.environ.get('DOCKER_DJANGO_SUPERUSER_PASSWORD', 'adminpassword')

if not User.objects.filter(username=username).exists():
    print(f"Creating superuser '{username}'...")

    User.objects.create_superuser(
        username=username,
        email=email,
        password=password
    )

    print(f"Superuser '{username}' created.")
else:
    print(f"Superuser '{username}' already exists.")
EOF

echo "Postgresql migrations finished"

exec gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:8020