module Workers
  class SyncRedisCounterToDbWorker
    include Sidekiq::Worker

    def perform(*args)
      threads = []

      threads << Thread.new do
        Rails.application.executor.wrap do
          sync_chats_count
        end
      end

      threads << Thread.new do
        Rails.application.executor.wrap do
          sync_messages_count
        end
      end

      threads.each(&:join)
    end

    private

    def sync_chats_count
      RedisService.sync_counter_data("application", Application, "chats_count")
    end

    def sync_messages_count
      RedisService.sync_counter_data("chat", Chat, "messages_count")
    end

  end
end