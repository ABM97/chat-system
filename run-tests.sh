docker compose -f ./docker-compose-test.yml build
docker compose -f ./docker-compose-test.yml up -d
docker logs -f chat-system-api-web-test-1
docker compose -f ./docker-compose-test.yml down