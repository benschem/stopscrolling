# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/activities', type: :request do
  let(:account) { create(:account, :verified) }
  let(:user) { account.user }

  before { sign_in(account) }

  describe 'GET /index' do
    subject(:request) { get activities_url }

    before do
      create(:activity, user: user)
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
        expect { request }.to change(user.activities, :count).by(1)
      end

      it 'redirects to the activities list' do
        request
        expect(response).to redirect_to(root_url)
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

    context 'with a name already on the list' do
      let(:name) { 'Read a book' }
      let(:params) { attributes_for(:activity, name: name) }

      before do
        create(:activity, user: user, name: name)
        request
      end

      it 'renders a response with 422 status' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'keeps their list on the page instead of the empty state' do
        expect(response.body).not_to include('Nothing here yet')
      end

      it 'leaves the rejected activity out of the list' do
        expect(response.body.scan('id="activity_read-a-book"').count).to eq(1)
      end
    end
  end

  describe 'POST /create rate limiting' do
    before do
      enable_rate_limiting
      20.times { |number| post activities_url, params: { activity: { name: "Activity number #{number}" } } }
    end

    it 'allows twenty within three minutes' do
      expect(user.activities.count).to eq(20)
    end

    context 'when a twenty first is posted' do
      before { post activities_url, params: { activity: { name: 'One too many' } } }

      it 'does not create it' do
        expect(user.activities.count).to eq(20)
      end

      it 'says to try again later' do
        expect(flash[:alert]).to eq('Try again later.')
      end
    end

    context 'when three minutes have passed' do
      before do
        travel 4.minutes
        post activities_url, params: { activity: { name: 'One later on' } }
      end

      it 'allows another' do
        expect(user.activities.count).to eq(21)
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:request) { delete activity_url(activity) }

    let!(:activity) { create(:activity, user: user) }

    it 'destroys the requested activity' do
      expect { request }.to change(Activity, :count).by(-1)
    end

    it 'redirects to the activities list' do
      request
      expect(response).to redirect_to(root_url)
    end

    context 'when the name has a dot in it' do
      let!(:activity) { create(:activity, user: user, name: 'Watch Dr. Who') }

      it 'destroys the requested activity' do
        expect { request }.to change(Activity, :count).by(-1)
      end
    end

    context 'when the name has a slash in it' do
      let!(:activity) { create(:activity, user: user, name: 'Cook/bake something') }

      it 'destroys the requested activity' do
        expect { request }.to change(Activity, :count).by(-1)
      end
    end

    context 'when the activity belongs to someone else' do
      let!(:activity) { create(:activity) }

      it 'does not destroy it' do
        expect { request }.not_to change(Activity, :count)
      end

      it 'redirects to the activities list' do
        request
        expect(response).to redirect_to(root_url)
      end

      it 'sets an alert' do
        request
        expect(flash[:alert]).to eq('That activity does not exist.')
      end
    end
  end

  describe 'GET /activities/random' do
    subject(:request) { get random_activities_url }

    before do
      create(:activity, user: user)
      request
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end
  end

  describe 'GET /activities/suggestion' do
    subject(:request) { get suggestion_activities_url }

    let(:suggestion_pool) { ACTIVITIES_LIST }

    before do
      stub_const('ACTIVITIES_LIST', suggestion_pool)
      create(:activity, user: user, name: 'Read a book')
      request
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end

    it 'still shows the list of activities' do
      expect(response.body).to include('Read a book')
    end

    context 'when only one suggestion is missing from their list' do
      let(:suggestion_pool) { ['Read a book', 'Go for a walk'] }

      it 'suggests the one they do not have yet' do
        expect(response.body).to include('go for a walk')
      end
    end

    context 'when their list already has everything we could suggest' do
      let(:suggestion_pool) { ['Read a book'] }

      it 'says so instead of suggesting a duplicate', :aggregate_failures do
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("You've already got everything we can think of.")
      end
    end
  end
end
