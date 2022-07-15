# Chat-system

> :warning: **The application rely on docker compose plugin that can run docker compose files of version 3.9!** 

> :warning: **Tested with```Docker Compose version v2.6.0```**


## System-components
- Rails-**7**
  - The back-end technology used for the back-end server
- MySQL
  - Database storage
- Redis
  - Caching service
- RabbitMQ
  - Async task queue
- ElasticSearch
  - Full Text search engine
- Sidekiq
  - Cron job with rails

## Overview
 - The goal is to build highly performant and concurrent chat system, mainly there will be applications each will be identified by an auto generated token and each application can have multiple chats which will be identified by an incremental number starting from 1 and the chat will have multiple messages which will be identified similarly as the chat, the messages will have a body represented as text and will be partially matched, and for each application the total chats count should be stored and for each chat the total messages count should be stored though this values are allowed to be delayed for 1 hour (not real time values).
 
 
 ## Flow Diagram
 
![chat_system drawio (2)](https://user-images.githubusercontent.com/25717199/179053717-29056869-c531-494a-8a09-e678cec47b16.png)

   - The user send creation request [chat-message] this request will be async, we will just get the incremental number from redis and publish creation task for rabbitMQ and send send the number back to the user.
   - A worker will consume task from rabbitMQ and insert the data to the database and Active model will send data to elastic search in case the task was message insertion
   - Another worker will run every hour to check if a count has been updated in the last hour and sync the counter data to the database.


### List of commands to test the app

The endpoints are exposed on port `3000`
#### Create new application

```sh
$ curl -X POST \
    http://localhost:3000/applications \
    -H 'content-type: application/json' \
    -d '{
  	    "name": "company-name"
     }'
```

#### Create new chat

```sh
$ curl -X POST \
    http://localhost:3000/applications/{application_token}/chats
```

#### Create new message

```sh
$ curl -X POST \
    http://localhost:3000/applications/{application_token}/chats/{chat_number}/messages \
    -H 'content-type: application/json' \
    -d '{
  	    "body": "message-body-content"
     }'
```

#### Search message content partially

```sh
$ curl -X GET \
    "http://localhost:3000/applications/{application_token}/chats/{chat_number}/messages?content={search_term}&page={page_number_0_based}&size={page_size}"
```

## Tests

> Similar to the application tests requires docker compose plugin that can run docker compose files of version 3.9 and the following command `./run-tests.sh` start it.
