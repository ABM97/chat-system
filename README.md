# Chat-system

## System-components
- Rails
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
 
  ![chat_system drawio](https://user-images.githubusercontent.com/25717199/178975640-771043bb-c681-41ad-9ec3-8304fbed252c.png)

   - The user send creation request [chat-message] this request will be async, we will just get the incremental number from redis and publish creation task for rabbitMQ and send send the number back to the user.
   - A worker will consume task from rabbitMQ and insert the data to the database.
   - Another worker will run every hour to check if a count has been updated in the last hour and sync the counter data to the database.
