#!/bin/bash
docker images | sed '1d' | awk '{print $1 " " $2 " " $3}' > images.list
docker save $(docker images -q) -o eigenhmi.tar
gzip eigenhmi.tar
