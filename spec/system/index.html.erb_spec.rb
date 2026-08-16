# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Activities index', type: :system do
  let(:account) { create(:account, :verified) }
  let(:user) { account.user }

  before do
    sign_in(account)
    create(:activity, user: user, name: 'Read a book')
    create(:activity, user: user, name: 'Write a book')
    visit activities_path
  end

  it 'shows a list of activities' do
    expect(page).to have_text('book', count: 2)
  end

  it 'displays a form to create a new activity' do
    expect(page).to have_button('Add')
  end

  context 'when the form is submitted with a valid name' do
    before do
      fill_in 'activity_name', with: 'New Activity'
      click_button 'Add'
    end

    it 'creates a new activity' do
      expect(page).to have_text('New activity')
    end
  end

  context 'when the form is submitted with an invalid name' do
    before do
      fill_in 'activity_name', with: ''
      click_button 'Add'
    end

    it 'shows an error' do
      expect(page).to have_text("Name can't be blank")
    end
  end

  context 'when an activity is deleted' do
    before do
      click_button 'Remove', match: :first
    end

    it 'removes it from the page' do
      expect(page).to have_text('book', count: 1)
    end
  end

  context 'when the user asks for something from their list' do
    before do
      click_button 'Something I like'
    end

    it 'displays a random activity' do
      expect(page).to have_css('.answer strong', text: /book/i)
    end
  end
end
