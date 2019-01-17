#!/bin/bash
gunzip eigenhmi.tar.gz 
docker load -i eigenhmi.tar
while read REPOSITORY TAG IMAGE_ID
do
  echo "== Tagging $REPOSITORY $TAG $IMAGE_ID =="
  docker tag "$IMAGE_ID" "$REPOSITORY:$TAG"
done < images.list