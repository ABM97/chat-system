require 'rails_helper'

RSpec.describe 'Applications API', type: :request do

  # Test suite for POST /applications
  describe 'POST /applications' do
    before do
      post "/applications", params: application_post_request_body, headers: json_content_type_header
    end
    context 'When application created successfully' do
      let!(:application_post_request_body) { { name: "test_app" }.to_json }
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json['name']).to eq("test_app")
        expect(json["token"]).not_to be(nil)
      end
    end
    context 'When application post request body is empty' do
      let!(:application_post_request_body) { {} }
      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not process that request.")
      end
    end
  end

  # Test suite for GET /applications
  describe 'INDEX GET /applications' do
    before do
      Application.create({ name: "test_company_1" })
      Application.create({ name: "test_company_2" })
      get "/applications"
    end
    context 'When applications retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json[0]['name']).to eq("test_company_1")
        expect(json[1]["name"]).to eq("test_company_2")
      end
    end
  end

  # Test suite for PUT /applications/:token
  describe 'PUT /applications/:token' do
    let!(:application) { Application.create({ name: "test_company_1" }) }

    before do
      put "/applications/#{application.token}", params: application_put_request_body, headers: json_content_type_header
    end

    context 'When application updated successfully' do
      let!(:application_put_request_body) { { name: "modified_name" }.to_json }
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
      it 'updated application correctly' do
        expect(Application.find_by(token: application.token)[:name]).to eq("modified_name")
      end
    end
    context 'When application put request body is empty' do
      let!(:application_put_request_body) { {} }
      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not process that request.")
      end
    end
    context 'When application request body has non permitted param' do
      let!(:application_put_request_body) { { token: "invalid" }.to_json }
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
      it 'successfully ignore non permitted param' do
        expect(Application.find_by(token: application.token)[:name]).to eq("test_company_1")
      end
    end
  end


  # Test suite for GET /applications/:token
  describe 'GET /applications' do
    let!(:application) { Application.create({ name: "test_company_1" }) }
    let!(:token) { application.token }

    before do
      get "/applications/#{token}"
    end

    context 'When application retrieved successfully' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'return correct response' do
        expect(json['name']).to eq("test_company_1")
      end
    end

    context 'When application token not exists' do
      let!(:token) { "invalid" }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'return correct response' do
        expect(json['error']['detail']).to eq("We could not find the object you were looking for.")
      end
    end
  end

end