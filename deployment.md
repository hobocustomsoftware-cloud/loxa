# Deployment Guide

This guide covers end‑to‑end deployment for the Loxa backend (Django 5.2, ASGI) across local, containers, and cloud environments. It is written for both developers and operations.

## 1) Prerequisites
- OS: Linux (Ubuntu 22.04/24.04) or macOS for local dev.
- Runtime: Python `3.12`, `pip`, and `virtualenv` for bare‑metal; or `Docker` 24+ and `docker compose` v2.
- Services: `PostgreSQL 16`, `Redis 7` (optional, recommended), `Nginx 1.27` for reverse proxy in prod.
- System packages (build): `build-essential`, `libpq-dev`, `curl`.
- Python dependencies: see `requirements.txt` (gunicorn/uvicorn, Django REST, allauth, simplejwt, cors, whitenoise, django-redis, drf-yasg, django-prometheus, etc.).

Required environment variables (from `loxa/loxa/settings.py`):
- Core: `DJANGO_SECRET_KEY`, `DJANGO_DEBUG` or `DEBUG`, `DJANGO_ALLOWED_HOSTS`
- Database: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT` (or `DATABASE_URL` in `.env.example`)
- Storage: `STATIC_ROOT`, `MEDIA_ROOT`
- Integrations: `AGORA_APP_ID`, `AGORA_APP_CERT`, `AGORA_TOKEN_TTL_SEC`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM_NUMBER`
- Observability: `SENTRY_DSN`
- Cache/async: `REDIS_URL` (defaults `redis://redis:6379/0`)
- Web workers (optional): `WEB_WORKERS`, `WEB_THREADS`, `WEB_WORKER_CLASS`, `WEB_TIMEOUT`

Example `.env` (start here and adjust per environment):
```
DJANGO_SECRET_KEY=generate-a-strong-secret
DJANGO_DEBUG=1
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

POSTGRES_DB=loxa_db
POSTGRES_USER=loxa_user
POSTGRES_PASSWORD=loxa@loxa
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

STATIC_ROOT=/data/static
MEDIA_ROOT=/data/media

AGORA_APP_ID=your_agora_app_id
AGORA_APP_CERT=your_agora_app_cert
AGORA_TOKEN_TTL_SEC=3600
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

REDIS_URL=redis://redis:6379/0
SENTRY_DSN=
WEB_WORKERS=3
WEB_THREADS=1
WEB_WORKER_CLASS=uvicorn.workers.UvicornWorker
WEB_TIMEOUT=60
```

## 2) Installation Steps (bare‑metal)
Use the nested backend app at `loxa/` for local Python runs.
- `cd loxa`
- Create a venv: `python3 -m venv .venv && source .venv/bin/activate`
- Install deps: `pip install -r requirements.txt`
- Copy env: `cp .env.example .env` and fill values (use `POSTGRES_HOST=localhost` for local DB)
- Prepare DB: create Postgres DB/user or run via Docker (see Compose below)
- Apply migrations: `python manage.py migrate`
- Create admin (optional): `python manage.py createsuperuser`
- Collect static: `python manage.py collectstatic --noinput`
- Run dev server: `python manage.py runserver 0.0.0.0:8000`

Database quick start (local Postgres):
- Create DB: `createdb loxa_db`
- Create user/password: `psql -c "CREATE USER loxa_user WITH PASSWORD 'loxa@loxa';"`
- Grant: `psql -c "GRANT ALL PRIVILEGES ON DATABASE loxa_db TO loxa_user;"`

Configuration files:
- `.env`: holds secrets and environment configs
- `loxa/loxa/gunicorn.conf.py`: tune `WEB_WORKERS`, `worker_class` and timeouts

## 3) Deployment Options

### A) Local (Docker Compose)
Option 1 (recommended, project‑scoped):
- `cd loxa`
- `cp .env.example .env` and edit values
- `docker compose up -d`  (uses `loxa/docker-compose.yml`)
  - Services: `web` (gunicorn/uvicorn), `nginx`, `redis`, `postgres`

Option 2 (repo root):
- `cp .env.example .env` (at repo root) and edit values
- `docker compose up -d`  (uses root `docker-compose.yml`)
  - Services: `web` (Django runserver for dev), `nginx`, `postgres`

Useful commands:
- Rebuild: `docker compose build --no-cache && docker compose up -d`
- Logs: `docker compose logs -f web` and `docker compose logs -f nginx`
- Migrate inside container: `docker compose exec web python manage.py migrate`

### B) Containerized (Docker only)
Build and run image directly (project‑scoped):
- `cd loxa`
- Build: `docker build -t loxa/web:latest -f deploy/Dockerfile .`
- Run:
  - `docker run --name loxa-web -p 8000:8000 --env-file .env -v loxa_static:/data/static -v loxa_media:/data/media loxa/web:latest`

### C) Cloud Deployments

AWS (ECR + ECS Fargate + RDS + ALB):
- Create ECR: `aws ecr create-repository --repository-name loxa`
- Authenticate: `aws ecr get-login-password | docker login --username AWS --password-stdin <acct>.dkr.ecr.<region>.amazonaws.com`
- Build/push: `docker build -t loxa/web:latest -f loxa/deploy/Dockerfile . && docker tag loxa/web:latest <acct>.dkr.ecr.<region>.amazonaws.com/loxa:latest && docker push <acct>.dkr.ecr.<region>.amazonaws.com/loxa:latest`
- Provision RDS (Postgres 16) and ElastiCache (Redis). Put creds into task env.
- Create ECS service with CPU/memory, assign ALB target group, set health check `/health/`.
- Set `DJANGO_ALLOWED_HOSTS` to your domain; put TLS on ALB.

GCP (Cloud Build + Cloud Run):
- Ensure `cloudbuild.yaml` (root) points to `loxa/deploy/Dockerfile`.
- Submit build: `gcloud builds submit --config cloudbuild.yaml --region <region>`
- Deploy: `gcloud run deploy loxa --image gcr.io/<project>/<repo>:$COMMIT_SHA --region <region> --allow-unauthenticated`
- Use Cloud SQL (Postgres) or external DB; set env vars in Cloud Run service.

Azure (ACR + Container Apps/App Service):
- Create ACR: `az acr create -n <acr> -g <rg> --sku Basic`
- Build/push: `az acr build -r <acr> -t loxa/web:latest -f loxa/deploy/Dockerfile .`
- Deploy to Container Apps: `az containerapp create ... --image <acr>.azurecr.io/loxa/web:latest --env-vars @loxa/.env`
- Use Azure Database for PostgreSQL and Azure Cache for Redis; set `DJANGO_ALLOWED_HOSTS` and TLS.

### D) CI/CD Integration
Option: GitHub Actions (push to registry, deploy to server via SSH):
```
name: deploy
on:
  push:
    branches: [ main ]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: ./loxa
          file: ./loxa/deploy/Dockerfile
          push: true
          tags: ghcr.io/<owner>/loxa:web-latest
      - name: Deploy (SSH)
        uses: appleboy/ssh-action@v1.1.0
        with:
          host: ${{ secrets.SSH_HOST }}
          username: ${{ secrets.SSH_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/loxa
            docker compose pull && docker compose up -d
            docker compose exec -T web python manage.py migrate
```
Option: GCP Cloud Build (already configured via `cloudbuild.yaml`).

## 4) Post‑Deployment
Verification checklist:
- Health: `curl -i http://<host>/health/` → `200 OK` (nginx prod config)
- App: `curl -i http://<host>/api/` and browse `http://<host>/swagger/`
- Auth: Obtain JWT at `POST /api/token/` and refresh at `/api/token/refresh/`
- Migrations: `docker compose exec web python manage.py showmigrations`
- Static/media present under `/static/` and `/media/`

Common troubleshooting:
- DB connection refused: validate `POSTGRES_*`, container network, security groups/firewalls.
- 400 `DisallowedHost`: set `DJANGO_ALLOWED_HOSTS` to include domain/IP.
- CORS issues: configure `CORS_ALLOWED_ORIGINS` in prod (see settings).
- OAuth callback mismatch: update Google OAuth redirect URIs to your domain.
- Redis missing: run `redis` service or set `REDIS_URL` to a reachable instance.
- Static files not served: run `collectstatic`, verify nginx mounts `/data/static`.
- 502 from nginx: check `web` logs; tune `WEB_WORKERS`, `WEB_TIMEOUT`.

Monitoring & logging:
- Sentry: set `SENTRY_DSN` to capture exceptions.
- Prometheus: `django_prometheus` middleware is enabled; add metrics endpoint (urls.py):
  `path("metrics/", include("django_prometheus.urls"))`
- Logs: web (gunicorn) prints to stdout; use `docker compose logs -f web` and `nginx` logs.

## 5) Maintenance
Updates:
- `git pull` (or CI build), then `docker compose pull && docker compose up -d`
- Apply migrations: `docker compose exec web python manage.py migrate`
- Rebuild on requirements changes: `docker compose build --no-cache`

Backups & recovery:
- Postgres: `pg_dump -U <user> -h <host> <db> > backup.sql` and restore with `psql <db> < backup.sql`
- Media/static: snapshot or archive `/data/media` and `/data/static` volumes
- Automate via cron or cloud backup services (S3/Blob/Cloud Storage)

Scaling considerations:
- Vertical: increase `WEB_WORKERS`, switch `WEB_WORKER_CLASS` to `uvicorn.workers.UvicornWorker` for ASGI, tune timeouts.
- Horizontal: run multiple `web` replicas behind nginx/ALB; ensure DB/Redis sizing; consider Cloud Run/ECS/Kubernetes.
- Rate limit sensitive endpoints via nginx (`limit_req` in `nginx.prod.conf`).

Appendix:
- Entrypoint: `loxa/deploy/entrypoint.web.sh` waits for DB, migrates, collects static, runs ASGI.
- Dockerfiles: both `deploy/Dockerfile` at repo root and `loxa/deploy/Dockerfile` exist; prefer project‑scoped (`loxa/`) for production builds.
- Compose files: `loxa/docker-compose.yml` (dev/prod ready) and root `docker-compose.yml` (simpler dev).
