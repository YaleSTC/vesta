# frozen_string_literal: true

require 'rails_helper'
require 'support/fake_profile_querier'
require 'rack-timeout'

RSpec.feature 'Admin creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'can be performed by other admins' do
    visit build_users_path
    submit_username('foo@example.com')
    submit_profile_data(first_name: 'John', last_name: 'Smith', role: 'admin')
    expect(page).to have_content('User John Smith created.')
  end

  context 'with IDR' do
    before do
      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('QUERIER')
                                .and_return('FakeProfileQuerier')
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(FakeProfileQuerier).to receive(:query)
        .and_raise(Rack::Timeout::RequestTimeoutException.new({}))
      # rubocop:enable RSpec/AnyInstance
    end

    it 'handles timeout' do
      visit build_users_path
      expect { submit_username('foo@example.com') }.not_to raise_error
    end
  end

  def submit_username(username)
    fill_in "user_#{User.login_attr}", with: username
    click_on 'Continue'
  end

  def submit_profile_data(first_name:, last_name:, role:)
    fill_in 'user_first_name', with: first_name
    fill_in 'user_last_name', with: last_name
    select role, from: 'user_role'
    click_on 'Create'
  end
end
