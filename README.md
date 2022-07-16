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

   - The user send creation request [chat/message] this request will be async, we will just get the incremental number from redis for each [chat/message] and publish a creation task on rabbitMQ and send send the number back to the user.
   - A worker will consume task from rabbitMQ and insert the data to the database and using elasticseacrh-model callbacks data will be sent to elastic search in case the task was message insertion
   - Another worker will run every 1/2 hour to check if any count has been updated in the last 1/2 hour and sync the counter data to the database.

## Design Decisions
  
### Redis
> **Redis will be used in two parts of the app**
 > - **Number generation:** due to it's single threaded design, REDIS can efficiently handle concurrent generation of incremental counter in fast, efficient and precise manner.
 > - **Batching updates of counter to db:** to avoid putting a lot of headache on the database and as it's allowed to delay counter updates for nearly an hour REDIS was a good choice for batching as much counter updates then flushing them to the database

### Elastic-search
> It was requested to match message content partially and this could be implemented in several ways in elastic search, it could be done using wildcards but this won't be efficient as elastic search will have to traverse all the index data to look for matches, in exchange of doing this costly operation wildcard will give 100% accurate results, another ways which what was implemented is to use custom analyser based on edegram with min-size of 3 and max-size of 10 and lowercase filters and a standard tokenizer to index the message content, the apply the analyser again to the search query to match results, this option will increase the performance dramatically but it won't be 100% percent accurate, accuracy could be improved further if more information was provided about the message content and the kind of search queries to be made.


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

## Future work
  - Shard the application data based on the application token [REDIS, MYSQL].
  - Multiple queues and multiple workers to leverage rabbitmq cluster features.
  - Multiple sync worker for the sharded redis data.
