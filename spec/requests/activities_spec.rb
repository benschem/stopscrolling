# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/activities', type: :request do
  describe 'GET /index' do
    subject(:request) { get activities_url }

    before do
      create(:activity)
      request
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    subject(:request) { post activities_url, params: { activity: params } }

    context 'with valid parameters' do
      let(:params) { attributes_for(:activity) }

      it 'creates a new Activity' do
        expect { request }.to change(Activity, :count).by(1)
      end

      it 'redirects to the activities list' do
        request
        expect(response).to redirect_to(activities_url)
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:activity, :invalid) }

      it 'does not create a new Activity' do
        expect { request }.not_to change(Activity, :count)
      end

      it 'renders a response with 422 status' do
        request
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:request) { delete activity_url(activity) }

    let!(:activity) { create(:activity) }

    it 'destroys the requested activity' do
      expect { request }.to change(Activity, :count).by(-1)
    end

    it 'redirects to the activities list' do
      request
      expect(response).to redirect_to(activities_url)
    end
  end
end
