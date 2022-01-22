docker-compose build

docker tag docker-github-action-runner_runner:latest pjabadesco/docker-github-action-runner:0.42
docker push pjabadesco/docker-github-action-runner:0.42

docker tag pjabadesco/docker-github-action-runner:0.42 pjabadesco/docker-github-action-runner:latest
docker push pjabadesco/docker-github-action-runner:latest

docker tag pjabadesco/docker-github-action-runner:latest ghcr.io/pjabadesco/docker-github-action-runner:latest
docker push ghcr.io/pjabadesco/docker-github-action-runner:latest
