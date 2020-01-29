#!/usr/bin/env sh
IDENTITY_FILE="$HOME/.ssh/wps12th.pem"
USER="ubuntu"
HOST="13.209.22.24"
TARGET=${USER}@${HOST}
ORIGIN_SOURCE="$HOME/projects/fastcampus/12th/instagram/"
DOCKER_REPO="azelf/wps-instagram"
SSH_CMD="ssh -i ${IDENTITY_FILE} ${TARGET}"

echo "== Docker 배포 =="

# 서버 초기설정
echo "apt update & upgrade & autoremove"
${SSH_CMD} -C 'sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y && apt -y autoremove'
echo "apt install docker.io"
${SSH_CMD} -C 'sudo apt -y install docker.io'

# docker build
echo "docker build"
docker build -q -t ${DOCKER_REPO} -f Dockerfile "${ORIGIN_SOURCE}"

# docker push
echo "docker push"
docker push ${DOCKER_REPO}

echo "docker stop"
${SSH_CMD} -C "sudo docker stop instagram"

echo "docker pull"
${SSH_CMD} -C "sudo docker pull ${DOCKER_REPO}"

# screen에서 docker run
echo "screen settings"
# 실행중이던 screen 세션종료
${SSH_CMD} -C 'screen -X -S docker quit'
# screen 실행
${SSH_CMD} -C 'screen -S docker -d -m'
# 실행중인 세션에 명령어 전달
${SSH_CMD} -C "screen -r docker -X stuff 'sudo docker run --rm -it -p 80:8000 --name=instagram azelf/wps-instagram\n'"

echo "  finish!"
