require 'rails_helper'

RSpec.describe 'Applications API', type: :request do

  let!(:application_post_request_body) { { name: "test_app" }.to_json }

  # Test suite for POST /applications

  describe 'POST /applications' do

    before { post "/applications", params: application_post_request_body, headers: json_content_type_header }

    context 'When application created successfully' do

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'return correct response' do
        expect(json['name']).to eq("test_app")
        expect(json["token"]).not_to be(nil)
      end

    end

    context 'When application request body is empty' do

      let!(:application_post_request_body) { {} }

      it 'returns status code 500' do
        expect(response).to have_http_status(500)
      end

      it 'return correct response' do
        expect(json['error']['detail']).to eq("param is missing or the value is empty: application")
      end

    end

  end
end