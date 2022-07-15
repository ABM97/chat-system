require 'rails_helper'

RSpec.describe 'Chats API', type: :request do

  let!(:application) { Application.create!({ name: "test_company_1" }) }
  let!(:application_token) { application.token }

  # Test suite for POST /applications/:token/chats'
  describe 'POST /applications/:token/chats' do
    before do
      post "/applications/#{application_token}/chats"
    end
    context 'When chat created successfully' do
      it 'returns status code 200' do
        Chat.transaction(isolation: :read_committed) do
          while Chat.count != 1
            sleep 0.2.seconds
          end
        end
        expect(response).to have_http_status(200)
      end

      it 'return correct response' do
        Chat.transaction(isolation: :read_committed) do
          while Chat.count != 1
            sleep 0.2.seconds
          end
        end
        expect(json['chat_number']).to eq(1)
      end

      it 'persist chat record in the database' do
        Chat.transaction(isolation: :read_committed) do
          while Chat.count != 1
            sleep 0.2.seconds
          end
          expect(Chat.where(application_id: application.id, number: 1)).not_to be(nil)
        end
      end
    end
  end

  # Test suite for Concurrent POST /applications/:token/chats'
  describe 'CONCURRENT POST /applications/:token/chats' do
    before do
      threads = []
      50.times do
        threads << Thread.new do
          post "/applications/#{application_token}/chats"
        end
      end
      threads.each(&:join)

    end
    context 'When chats created successfully' do
      it 'persist multiple chats records in the database' do
        Chat.transaction(isolation: :read_committed) do
          while Chat.count != 50
            sleep 0.2.seconds
          end
          expect(Chat.where(application_id: application.id).maximum(:number)).to be(50)
        end
      end
    end
  end

  # Test suite for GET /applications/:token/chats
  describe 'INDEX GET /applications/:token/chats' do
    before do
      Chat.create({ application_id: application.id, number: 1, check_sum: SecureRandom.uuid })
      Chat.create({ application_id: application.id, number: 2, check_sum: SecureRandom.uuid })
      get "/applications/#{application_token}/chats"
    end
    context 'When chats retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json[0]['number']).to eq(1)
        expect(json[1]["number"]).to eq(2)
      end
    end

    context 'When chats retrieval failed non existing application token' do
      let!(:application_token) { "invalid" }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not find the object you were looking for.")
      end
    end
  end

  # Test suite for GET /applications/:application_token/chats/:number
  describe 'GET /applications/:application_token/chats/:number' do
    let!(:chat) { Chat.create({ application_id: application.id, number: 1, check_sum: SecureRandom.uuid }) }
    let!(:chat_number) { chat.number }
    before do
      get "/applications/#{application_token}/chats/#{chat_number}"
    end
    context 'When chat retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json['number']).to eq(1)
      end
    end

    context 'When chat retrieval failed non existing chat number' do
      let!(:chat_number) { 4 }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not find the object you were looking for.")
      end
    end
  end

end