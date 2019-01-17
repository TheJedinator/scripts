#!/bin/bash
docker-compose up --no-start mongo
yes | docker-compose up --no-start zmq-service
