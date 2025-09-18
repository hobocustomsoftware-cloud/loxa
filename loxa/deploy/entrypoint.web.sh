#!/usr/bin/env bash
set -euo pipefail

# Wait for DB
python - <<'PY'
import time, psycopg2, os
for _ in range(30):
    try:
        psycopg2.connect(
            dbname=os.getenv("POSTGRES_DB","loxa_db"),
            user=os.getenv("POSTGRES_USER","loxa_user"),
            password=os.getenv("POSTGRES_PASSWORD","postgrespass"),
            host=os.getenv("POSTGRES_HOST","postgres"),
            port=os.getenv("POSTGRES_PORT","5432"),
            connect_timeout=3,
        ).close()
        break
    except Exception:
        time.sleep(1)
PY

# Migrate + collect static
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# Minimal health endpoint if you haven't added yet:
#   path("healthz/", lambda r: HttpResponse("ok"))
# Run ASGI server (Daphne works for future Channels)
exec daphne -b 0.0.0.0 -p 8000 loxa.asgi:application gunicorn loxa.asgi:application -k uvicorn.workers.UvicornWorker -c gunicorn.conf.py

python manage.py collectstatic --noinput


