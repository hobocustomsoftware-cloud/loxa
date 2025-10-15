# Deployment Guide

```bash
# copy .env.example to .env
cp .env.example .env
# update .env with appropriate service credential
# up and running 
docker compose up

```



cd /home/loxalms/public_html/loxa
sudo docker-compose -f docker-compose.yml build --no-cache
sudo docker-compose -f docker-compose.yml up -d
