class DbInsertionWorker
  include Sneakers::Worker

  from_queue "db_tasks"

  def work(raw_post)
    ActiveRecord::Base.connection_pool.with_connection do
      job_data = JSON.parse(raw_post)
      begin
        if job_data["table"] == "Chat"
          handle_chat_task(job_data)
        else
          handle_message_task(job_data)
        end
        ack!
      rescue Exception => error
        puts error.message
      end
    end
    ActiveRecord::Base.connection.close
  end

  private

  def handle_chat_task(job_data)
    chat = Chat.find_by(number: job_data["number"], application_id: job_data["application_id"])
    if chat.nil?
      Chat.create!({ number: job_data["number"], application_id: job_data["application_id"], check_sum: job_data["check_sum"] });
    else
      unless chat.check_sum == job_data["check_sum"]
        # handling mechanism should be implemented, 2 different objects got the same number redis fail to persist data and died before calling fsync
        RabbitmqPublisher.publish("number_generation_failures", job_data)
      end
    end
  end

  def handle_message_task(job_data)
    message = Message.find_by(number: job_data["number"], chat_id: job_data["chat_id"])
    if message.nil?
      Message.create!({ number: job_data["number"], body: job_data["body"], chat_id: job_data["chat_id"], check_sum: job_data["check_sum"] });
    else
      unless message.check_sum == job_data["check_sum"]
        # handling mechanism should be implemented, 2 different objects got the same number redis fail to persist data and died before calling fsync
        RabbitmqPublisher.publish("number_generation_failures", job_data)
      end
    end
  end


end