require 'rails_helper'

RSpec.describe 'Api::V1::Authentication', type: :request do
  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns user data and token in header' do
        post '/api/v1/auth/login', params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.headers['Authorization']).to be_present

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['user']['email']).to eq(user.email)
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized' do
        post '/api/v1/auth/login', params: {
          user: {
            email: user.email,
            password: 'wrongpassword'
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:user) { create(:user) }

    context 'with valid token' do
      it 'returns current user data' do
        # Login to get token
        post '/api/v1/auth/login', params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }, as: :json

        token = response.headers['Authorization']

        get '/api/v1/auth/me', headers: {
          'Authorization' => token
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['email']).to eq(user.email)
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        get '/api/v1/auth/me'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    let(:user) { create(:user) }

    context 'with valid token' do
      it 'logs out successfully' do
        # Login to get token
        post '/api/v1/auth/login', params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }, as: :json

        token = response.headers['Authorization']

        delete '/api/v1/auth/logout', headers: {
          'Authorization' => token
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
      end
    end
  end
end
