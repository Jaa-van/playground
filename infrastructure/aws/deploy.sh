#!/bin/bash
# EC2 배포 스크립트
# 사용법: ./deploy.sh <EC2-PUBLIC-IP>

set -e

EC2_IP="${1:?EC2 IP를 인수로 전달하세요: ./deploy.sh <EC2-IP>}"
EC2_HOST="ubuntu@${EC2_IP}"
EC2_DIR="/home/ubuntu/app"

echo "=== EC2 배포 시작: ${EC2_IP} ==="

echo "--- 코드 업데이트 ---"
ssh "$EC2_HOST" "cd ${EC2_DIR} && git pull origin main"

echo "--- 컨테이너 재시작 ---"
ssh "$EC2_HOST" "cd ${EC2_DIR}/infrastructure && docker compose -f docker-compose.yml up -d --build"

echo "=== 배포 완료 ==="
echo "접속: http://${EC2_IP}"
