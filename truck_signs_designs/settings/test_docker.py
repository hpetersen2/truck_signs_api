import os
import environ
from .base import *

env = environ.Env()

environ.Env.read_env(
    os.path.join(
        os.path.dirname(__file__),
        "simple_env_config.env"
    )
)

SECRET_KEY = env("DOCKER_SECRET_KEY")
DEBUG = env("DEBUG")

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
]



DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': env('DOCKER_DB_NAME'),
        'USER': env('DOCKER_DB_USER'),
        'PASSWORD': env('DOCKER_DB_PASSWORD'),
        'HOST': env('DOCKER_DB_HOST'),
        'PORT': env('DOCKER_DB_PORT'),
    }
}

STRIPE_PUBLISHABLE_KEY=env("DOCKER_STRIPE_PUBLISHABLE_KEY")
STRIPE_SECRET_KEY=env("DOCKER_STRIPE_SECRET_KEY")



EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_USE_TLS = True
EMAIL_PORT = 587
EMAIL_HOST_USER = env("DOCKER_EMAIL_HOST_USER")
EMAIL_HOST_PASSWORD = env("DOCKER_EMAIL_HOST_PASSWORD")