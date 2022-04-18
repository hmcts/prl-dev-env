#!/usr/bin/env bash

docker-compose stop
docker-compose down --volumes
docker system prune -f
docker volume prune -f