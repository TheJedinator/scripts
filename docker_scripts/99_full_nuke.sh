#!/bin/bash
set -e
containers=$(docker ps -aq)
for container in $containers
  do 
    docker rm -f $container
done
images=$(docker images -aq)
for image in $images
  do 
    docker rmi -f $image
done
#sudo rm -rf /var/lib/docker/volumes