# GITHUB ACTION RUNNER

docker-compose build
docker-compose up --scale runner=2 -d
docker service scale actions_runner=3
docker run -it docker-github-action-runner_runner
docker rm $(docker ps -a -q)
docker volume prune

 docker compose -f docker-compose.yml -f docker-compose.admin.yml run backup_db

<https://testdriven.io/blog/github-actions-docker/>

<https://medium.com/geekculture/docker-build-with-mac-m1-d668c802ab96>
docker buildx build --platform linux/amd64 ./

docker system prune -a
