# AWS EC2 배포 가이드 (Phase 2)

## 인스턴스 스펙 권장

| 항목 | 권장 | 비고 |
|------|------|------|
| 인스턴스 타입 | t3.small | 개발/테스트: t3.micro |
| OS | Ubuntu 22.04 LTS | |
| 스토리지 | 20GB gp3 | |
| 보안 그룹 | 80 (HTTP), 443 (HTTPS), 22 (SSH) | 22는 내 IP만 |

## EC2 초기 설정 (`infrastructure/aws/ec2-setup.sh`)

SSH 접속 후 실행:

```bash
#!/bin/bash
# Docker 설치
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 현재 사용자를 docker 그룹에 추가 (재로그인 필요)
sudo usermod -aG docker $USER
```

## 배포 (`infrastructure/aws/deploy.sh`)

로컬에서 EC2로 코드 동기화 후 실행:

```bash
#!/bin/bash
EC2_HOST="ubuntu@<EC2-PUBLIC-IP>"
EC2_DIR="/home/ubuntu/app"

# 코드 동기화 (git pull 방식 권장)
ssh $EC2_HOST "cd $EC2_DIR && git pull origin main"

# 환경변수 파일은 별도로 관리 (git에 포함 금지)
# 최초 1회: scp .env.production $EC2_HOST:$EC2_DIR/.env

# 컨테이너 재시작
ssh $EC2_HOST "cd $EC2_DIR/infrastructure && docker compose -f docker-compose.yml up -d --build"
```

## EC2 운영 실행

```bash
# override 없이 base 파일만 사용 (pgAdmin 없음, hot reload 없음)
cd infrastructure
docker compose -f docker-compose.yml up -d
```

## HTTPS 설정 (선택 - 도메인 있을 때)

Nginx + Certbot으로 Let's Encrypt SSL:

```bash
# EC2에서
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

## 환경변수 관리

`.env` 파일은 **절대 git에 커밋하지 않습니다**.

EC2에 최초 1회 수동 복사:
```bash
scp .env.production ubuntu@<EC2-IP>:/home/ubuntu/app/.env
```

이후 변경 시:
```bash
ssh ubuntu@<EC2-IP> "nano /home/ubuntu/app/.env"
ssh ubuntu@<EC2-IP> "cd /home/ubuntu/app/infrastructure && docker compose -f docker-compose.yml up -d"
```

## 로그 확인

```bash
ssh ubuntu@<EC2-IP>
cd ~/app/infrastructure
docker compose -f docker-compose.yml logs -f backend
docker compose -f docker-compose.yml logs -f nginx
```
