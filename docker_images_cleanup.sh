docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")
docker rm $(docker ps -a -q -f status=exited)
