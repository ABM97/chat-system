#!/bin/sh
docker compose -p 'chat-system' -f ./docker-compose-test.yml build
docker compose -p 'chat-system' -f ./docker-compose-test.yml  up -d
docker logs -f $(docker ps | grep "chat-system_web-test" | awk '{print $1}')
docker compose -p 'chat-system' -f ./docker-compose-test.yml down