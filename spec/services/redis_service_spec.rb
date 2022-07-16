require 'rails_helper'

RSpec.describe 'Redis service', type: :request do

  let!(:application) { Application.create!({ name: "test_company_1" }) }
  let!(:application_token) { application.token }

  # Test suite for POST /applications/:token/chats'
  describe 'Sync counters data from redis to db' do
    before do
      threads = []
      threads << Thread.new do
        post "/applications/#{application_token}/chats"
        post "/applications/#{application_token}/chats"
      end
      threads << Thread.new do
        Chat.transaction(isolation: :read_committed) do
          while Chat.count != 2
            sleep 0.2.seconds
          end
        end
        post "/applications/#{application_token}/chats/2/messages", params: { body: "hello test company" }.to_json, headers: json_content_type_header
        post "/applications/#{application_token}/chats/1/messages", params: { body: "hello test company" }.to_json, headers: json_content_type_header
      end
      threads.each(&:join)
      count = Message.count
      Message.transaction(isolation: :read_committed) do
        while count != 2
          count = Message.count
          sleep 0.2.seconds
        end
      end
      RedisService.sync_counter_data("application", Application, "chats_count")
      RedisService.sync_counter_data("chat", Chat, "messages_count")
    end
    context 'Sync done successfully' do
      it 'Counters updated' do
        chat = Chat.find_by!(number: 1)
        expect(chat[:messages_count]).to eq(1)

        chat = Chat.find_by!(number: 2)
        expect(chat[:messages_count]).to eq(1)

        application = Application.find_by!(id: chat.application_id)
        expect(application[:chats_count]).to eq(2)
      end

    end
  end
end
