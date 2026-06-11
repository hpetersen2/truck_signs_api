<div align="center">

![Truck Signs](./screenshots/Truck_Signs_logo.png)

# Signs for Trucks

![Python version](https://img.shields.io/badge/Pythn-3.8.10-4c566a?logo=python&&longCache=true&logoColor=white&colorB=pink&style=flat-square&colorA=4c566a) ![Django version](https://img.shields.io/badge/Django-2.2.8-4c566a?logo=django&&longCache=truelogoColor=white&colorB=pink&style=flat-square&colorA=4c566a) ![Django-RestFramework](https://img.shields.io/badge/Django_Rest_Framework-3.12.4-red.svg?longCache=true&style=flat-square&logo=django&logoColor=white&colorA=4c566a&colorB=pink)

</div>

## Table of Contents

- [Description](#description)
- [Quickstart](#quickstart)
  - [Prerequisites](#prerequisites)
  - [How to Build the Image](#how-to-build-the-image)
  - [Run the Application](#run-the-application)
  - [Stop the Application](#stop-the-application)
- [Usage](#usage)
  - [Environment Variables](#environment-variables)
  - [Docker Commands in Detail](#docker-commands-in-detail)
  - [Persistence](#persistence)
- [Screenshots of the Django Backend Admin Panel](#screenshots)
- [Useful Links](#useful-links)

---

## Description

**Signs for Trucks** is an online store to buy pre-designed vinyls with custom lines of letters (often called truck letterings). The store also allows clients to upload their own designs and customize them on the website. Aside from the main vinyl products, clients can also purchase simple lettering vinyls, fire extinguisher vinyls, and vinyls with a unit number.

This repository contains the **Dockerized Django REST API backend** for the Signs for Trucks application. The setup runs the Django application and a PostgreSQL database each in their own container, connected via a shared Docker network. Data is persisted using a named Docker volume. The application is served by Gunicorn on port `8020`.

### Settings

The `settings` folder inside `truck_signs_designs` contains configuration for each environment (development, docker, production) as extensions of `base.py`. The active environment is Docker by default. To switch environments, modify `__init__.py`.

### Models

- **Category** — vinyl category (e.g. Truck Logo, Fire Extinguisher)
- **Lettering Item Category** — type of lettering line with its own pricing (e.g. Company Name, VIM Number)
- **Lettering Item Variations** — a lettering category with the client's custom text
- **Product Variation** — a product with client-added lettering lines
- **Order** — the cart plus contact and shipping information
- **Payment** — payment metadata including Stripe client ID and purchase timestamp

---

## Quickstart

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- A `.env` file in the project root (see [Environment Variables](#environment-variables))

### How to Build the Image

**Mac / Linux**
```bash
docker build -t truck-signs-api .
```

### Run the Application

The application requires a Docker network, a volume for database persistence, a running PostgreSQL container, and then the app container itself.

**Mac / Linux**
```bash
# 1. Create network and volume (only needed once)
docker network create trucksigns-net
docker volume create trucksigns-pgdata

# 2. Start PostgreSQL
docker run -d \
  --name db \
  --network trucksigns-net \
  --restart unless-stopped \
  --env-file .env \
  -v trucksigns-pgdata:/var/lib/postgresql/data \
  postgres:14

# 3. Start the Django app
docker run -d \
  --name truck-signs-api \
  --network trucksigns-net \
  --restart unless-stopped \
  -p 8020:8020 \
  --env-file .env \
  truck-signs-api
```

The API is available at `http://localhost:8020`.  
The Django admin panel is available at `http://localhost:8020/admin`.

### Stop the Application

**Mac / Linux**
```bash
docker stop truck-signs-api db
docker rm truck-signs-api db
```

> The Docker volume `trucksigns-pgdata` is not removed by these commands. Your database data is preserved and will be available the next time you start the containers.

---

## Usage

### Environment Variables

Create a `.env` file in the project root by copying the provided template, then fill in your values. **Never commit this file to version control** — it is listed in `.gitignore`.

**Mac / Linux**
```bash
cp .env.template .env
```

> `DATABASE_HOST` and `DOCKER_DB_HOST` must be set to `db` — this is the container name of the PostgreSQL container and how the two containers find each other within the Docker network.

### Docker Commands in Detail

**View logs**

```bash
# Mac / Linux
docker logs truck-signs-api
docker logs -f truck-signs-api   # follow live

**Open a shell inside the running container**

```bash
# Mac / Linux
docker exec -it truck-signs-api bash


**Remove everything including the volume (⚠️ deletes all database data)**

```bash
# Mac / Linux
docker stop truck-signs-api db
docker rm truck-signs-api db
docker volume rm trucksigns-pgdata
docker network rm trucksigns-net

### Persistence

Database data is stored in the named Docker volume `trucksigns-pgdata`, which is mounted into the PostgreSQL container at `/var/lib/postgresql/data`. Stopping or removing the containers does **not** delete the volume. Data is only lost if the volume is explicitly removed with `docker volume rm trucksigns-pgdata`.

### Entrypoint Behavior

On every container start, `entrypoint.sh` automatically:

1. Waits for PostgreSQL to be ready
2. Writes the runtime `.env` file for Django into `truck_signs_designs/settings/`
3. Runs `python manage.py migrate`
4. Runs `python manage.py collectstatic --noinput`
5. Creates the Django superuser if it does not already exist
6. Starts the application via Gunicorn on port `8020`

---

<a name="screenshots"></a>

## Screenshots of the Django Backend Admin Panel

### Mobile View

<div align="center">

![alt text](./screenshots/Admin_Panel_View_Mobile.png) ![alt text](./screenshots/Admin_Panel_View_Mobile_2.png) ![alt text](./screenshots/Admin_Panel_View_Mobile_3.png)

</div>

---

### Desktop View

![alt text](./screenshots/Admin_Panel_View.png)

---

![alt text](./screenshots/Admin_Panel_View_2.png)

---

![alt text](./screenshots/Admin_Panel_View_3.png)

---

## Useful Links

### Docker
- [Docker Official Documentation](https://docs.docker.com/)
- Dockerizing Django, PostgreSQL, Gunicorn, and Nginx:
  - GitHub repo by sunilale0: [Link](https://github.com/sunilale0/django-postgresql-gunicorn-nginx-dockerized/blob/master/README.md#nginx)
  - Michael Herman on testdriven.io: [Link](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)

### Django and DRF
- [Django Official Documentation](https://docs.djangoproject.com/en/4.0/)
- [Django Rest Framework Official Documentation](https://www.django-rest-framework.org/)
- Generate a new secret key: [Stackoverflow Link](https://stackoverflow.com/questions/41298963/is-there-a-function-for-generating-settings-secret-key-in-django)
- Modify the Django Admin: [Real Python](https://realpython.com/customize-django-admin-python/)

### PostgreSQL
- Setup Database: [Digital Ocean — Django on VPS](https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-16-04)

### Miscellaneous
- [Configure CORS](https://www.stackhawk.com/blog/django-cors-guide/)
- [Setup Django with Cloudinary](https://cloudinary.com/documentation/django_integration)