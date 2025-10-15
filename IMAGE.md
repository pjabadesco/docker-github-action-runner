## OLD

docker-compose build

## NEW

docker buildx build --platform=linux/amd64 --tag=docker-github-action-runner:latest --load .

docker tag docker-github-action-runner:latest pjabadesco/docker-github-action-runner:2.329.0
docker push pjabadesco/docker-github-action-runner:2.329.0

docker tag pjabadesco/docker-github-action-runner:2.329.0 pjabadesco/docker-github-action-runner:latest
docker push pjabadesco/docker-github-action-runner:latest

docker tag pjabadesco/docker-github-action-runner:latest ghcr.io/pjabadesco/docker-github-action-runner:latest
docker push ghcr.io/pjabadesco/docker-github-action-runner:latest
