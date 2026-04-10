#!/bin/bash
# EC2 Ubuntu 22.04 초기 설정 스크립트
# 사용법: ssh ubuntu@<EC2-IP> 'bash -s' < ec2-setup.sh

set -e

echo "=== Docker 설치 ==="
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== 현재 사용자를 docker 그룹에 추가 ==="
sudo usermod -aG docker $USER

echo "=== 프로젝트 디렉토리 생성 ==="
mkdir -p ~/app

echo "=== 완료 ==="
echo "재로그인 후 docker 명령어를 사용할 수 있습니다."
echo "다음 단계: git clone <repo-url> ~/app"
