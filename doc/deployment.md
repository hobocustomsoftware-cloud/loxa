# Deployment Guide

```bash
# copy .env.example to .env
cp .env.example .env
# update .env with appropriate service credential
# up and running 
docker compose up

cd /home/loxalms/public_html/loxa
sudo docker-compose -f docker-compose.yml build --no-cache
sudo docker-compose -f docker-compose.yml up -d

```

## Creating superuser

```bash
docker compose exec web bash -lc 'DJANGO_SUPERUSER_USERNAME=admin DJANGO_SUPERUSER_EMAIL=admin@example.com DJANGO_SUPERUSER_PASSWORD=Admin@123 python manage.py createsuperuser --noinput --username admin --email admin@example.com' 
```





