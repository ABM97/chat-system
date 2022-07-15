require 'rails_helper'

RSpec.describe 'Messages API', type: :request do

  let!(:application) { Application.create!({ name: "test_company_1" }) }
  let!(:application_token) { application.token }
  let!(:chat) { Chat.create!({ number: 1, application_id: application.id, check_sum: SecureRandom.uuid }) }
  let!(:chat_number) { chat.number }

  # Test suite for POST /applications/:token/chats/:chat_number/messages
  describe 'POST /applications/:token/chats/:chat_number/messages' do
    before do
      post "/applications/#{application_token}/chats/#{chat_number}/messages", params: { body: "hello test company" }.to_json, headers: json_content_type_header
    end
    context 'When message created successfully' do
      it 'returns status code 200' do
        Message.transaction(isolation: :read_committed) do
          while Message.count != 1
            sleep 0.2.seconds
          end
        end
        expect(response).to have_http_status(200)
      end

      it 'return correct response' do
        Message.transaction(isolation: :read_committed) do
          while Message.count != 1
            sleep 0.2.seconds
          end
        end
        expect(json['message_number']).to eq(1)
      end

      it 'persist message record in the database' do
        Message.transaction(isolation: :read_committed) do
          while Message.count != 1
            sleep 0.2.seconds
          end
          expect(Message.where(chat_id: chat.id, number: 1)).not_to be(nil)
        end
      end

      it 'persist message document in elastic search index' do
        Message.transaction(isolation: :read_committed) do
          while Message.count != 1
            sleep 0.2.seconds
          end
        end

        while Message.__elasticsearch__.client.count(index: Message.index_name)['count'] != 1
          sleep 0.2.seconds
        end

      end
    end
  end

  # Test suite for Concurrent POST /applications/:token/chats/:chat_number/messages
  describe 'CONCURRENT POST /applications/:token/chats/:chat_number/messages' do
    before do
      threads = []
      50.times do
        threads << Thread.new do
          post "/applications/#{application_token}/chats/#{chat_number}/messages", params: { body: "hello test company" }.to_json, headers: json_content_type_header
        end
      end
      threads.each(&:join)

    end
    context 'When messages created successfully' do
      it 'persist multiple messages records in the database' do
        Message.transaction(isolation: :read_committed) do
          while Message.count != 50
            sleep 0.2.seconds
          end
          expect(Message.where(chat_id: chat.id).maximum(:number)).to be(50)
        end
      end

      it 'persist messages documents in elastic search index' do
        Message.transaction(isolation: :read_committed) do
          while Message.count != 50
            sleep 0.2.seconds
          end
        end
        while Message.__elasticsearch__.client.count(index: Message.index_name)['count'] != 50
          sleep 0.2.seconds
        end

      end
    end
  end

  # Test suite for GET /applications/:token/chats/:chat_number/messages
  describe 'GET /applications/:token/chats/:chat_number/messages' do
    before do
      Message.create({ chat_id: chat.id, number: 1, check_sum: SecureRandom.uuid, body: "Hello world" })
      Message.create({ chat_id: chat.id, number: 2, check_sum: SecureRandom.uuid, body: "Hello worlds" })
      get "/applications/#{application_token}/chats/#{chat_number}/messages"
    end
    context 'When messages retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json[0]['number']).to eq(1)
        expect(json[0]['body']).to eq("Hello world")
        expect(json[1]["number"]).to eq(2)
        expect(json[1]['body']).to eq("Hello worlds")
      end
    end

    context 'When messages retrieval failed non existing application token' do
      let!(:chat_number) { 90 }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not find the object you were looking for.")
      end
    end
  end

  # Test suite for GET /applications/:application_token/chats/:chat_number/messages/:number
  describe 'INDEX GET /applications/:application_token/chats/:chat_number/messages/:number' do
    let!(:message) { Message.create({ chat_id: chat.id, number: 1, check_sum: SecureRandom.uuid, body: "Hello world" }) }
    let!(:message_number) { message.number }
    before do
      get "/applications/#{application_token}/chats/#{chat_number}/messages/#{message_number}"
    end
    context 'When message retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json['number']).to eq(1)
        expect(json['body']).to eq("Hello world")
      end
    end

    context 'When message retrieval failed non existing message number' do
      let!(:message_number) { 4 }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not find the object you were looking for.")
      end
    end
  end

  # Test suite for GET /applications/:application_token/chats/:chat_number/messages/:number
  describe 'ES GET /applications/:application_token/chats/:chat_number/messages/:number' do
    before do
      post "/applications/#{application_token}/chats/#{chat_number}/messages", params: { body: "hello" }.to_json, headers: json_content_type_header
      post "/applications/#{application_token}/chats/#{chat_number}/messages", params: { body: "ehlo" }.to_json, headers: json_content_type_header
      Message.transaction(isolation: :read_committed) do
        while Message.where(chat_id: chat.id).count != 2 || Message.__elasticsearch__.client.count(index: Message.index_name)['count'] != 2
          sleep 0.2.seconds
        end
        get "/applications/#{application_token}/chats/#{chat_number}/messages", params: { page: 0, size: 2, content: "hello" }
      end
    end
    context 'When message retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json.size).to eq(1)
        expect(json[0]['message_body']).to eq("hello")
      end
    end
  end

  # Test suite for PUT /applications/:application_token/chats/:chat_number/messages/:number
  describe 'PUT /applications/:application_token/chats/:chat_number/messages/:number' do
    let!(:message) { Message.create({ chat_id: chat.id, number: 1, check_sum: SecureRandom.uuid, body: "Hello world" }) }
    let!(:message_number) { message.number }

    before do
      put "/applications/#{application_token}/chats/#{chat_number}/messages/#{message_number}", params: message_put_request_body.to_json, headers: json_content_type_header
    end

    context 'When message updated successfully' do
      let!(:message_put_request_body) { { body: "hello test company" } }
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
      it 'updated application correctly' do
        expect(Message.find_by(id: message.id)[:body]).to eq("hello test company")
      end

      it 'updated in elastic search correctly' do
        sleep 1.seconds # re-index interval segments merging
        value = Message.__elasticsearch__.search(query: { match: { "chat.id": chat.id } })
        not_matched = true
        while value.nil? || not_matched
          sleep 0.2.seconds
          value = Message.__elasticsearch__.search(query: { match: { "chat.id": chat.id } })
          not_matched = value.nil? ? false : value[0][:_source][body] == "hello test company"
        end
      end
    end

    context 'When message put request body is empty' do
      let!(:message_put_request_body) { {} }
      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not process that request.")
      end
    end

    context 'When message request body has non permitted param' do
      let!(:message_put_request_body) { { chat_id: 1232, body: "hello test company" } }
      it 'returns status code 204' do
        p response.body
        expect(response).to have_http_status(204)
      end
      it 'successfully ignore non permitted param' do
        updated_message = Message.find_by(id: message.id)
        expect(updated_message[:chat_id]).to eq(chat.id)
        expect(updated_message[:body]).to eq("hello test company")
      end
    end
  end

end