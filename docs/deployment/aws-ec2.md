# AWS EC2 Deployment Guide (Phase 2)

## Recommended Instance Specs

| Item | Recommended | Notes |
|------|------------|-------|
| Instance type | t3.small | dev/test: t3.micro |
| OS | Ubuntu 22.04 LTS | |
| Storage | 20GB gp3 | |
| Security group | 80 (HTTP), 443 (HTTPS), 22 (SSH) | SSH from your IP only |

## EC2 Initial Setup (`infrastructure/aws/ec2-setup.sh`)

Run after SSH login:

```bash
#!/bin/bash
# install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# add current user to docker group (requires re-login)
sudo usermod -aG docker $USER
```

## Deploy (`infrastructure/aws/deploy.sh`)

Sync code to EC2 and run:

```bash
#!/bin/bash
EC2_HOST="ubuntu@<EC2-PUBLIC-IP>"
EC2_DIR="/home/ubuntu/app"

# sync code (git pull preferred)
ssh $EC2_HOST "cd $EC2_DIR && git pull origin main"

# env file is managed separately (never in git)
# first time only: scp .env.production $EC2_HOST:$EC2_DIR/.env

# restart containers
ssh $EC2_HOST "cd $EC2_DIR/infrastructure && docker compose -f docker-compose.yml up -d --build"
```

## EC2 Production Start

```bash
# use base file only — no override (no pgAdmin, no hot reload)
cd infrastructure
docker compose -f docker-compose.yml up -d
```

## HTTPS Setup (optional — when you have a domain)

Nginx + Certbot for Let's Encrypt SSL:

```bash
# on EC2
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

## Environment Variable Management

`.env` files must **never be committed to git**.

Copy to EC2 manually on first setup:
```bash
scp .env.production ubuntu@<EC2-IP>:/home/ubuntu/app/.env
```

After changes:
```bash
ssh ubuntu@<EC2-IP> "nano /home/ubuntu/app/.env"
ssh ubuntu@<EC2-IP> "cd /home/ubuntu/app/infrastructure && docker compose -f docker-compose.yml up -d"
```

## Log Inspection

```bash
ssh ubuntu@<EC2-IP>
cd ~/app/infrastructure
docker compose -f docker-compose.yml logs -f backend
docker compose -f docker-compose.yml logs -f nginx
```
