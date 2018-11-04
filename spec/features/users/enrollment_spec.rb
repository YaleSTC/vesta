# frozen_string_literal: true

require 'rails_helper'
require 'support/fake_profile_querier'
require 'rack-timeout'

RSpec.feature 'User enrollment' do
  before do
    log_in(create(:admin))
    allow(ENV).to receive(:[]).and_return(nil)
    allow(ENV).to receive(:[]).with('QUERIER').and_return('FakeProfileQuerier')
  end

  context 'when updating existing users' do
    before do
      create_pair(:user)
    end

    it 'succeeds' do
      visit_new_enrollment_path
      list_of_ids = [User.first.email, User.second.email].join(',')
      fill_out_form(list_of_ids)
      click_on 'Submit'
      expect(page).to have_content('Successfully created/updated 2 users:')
    end

    def fill_out_form(list_of_ids)
      fill_in 'enrollment_ids', with: list_of_ids
      select 'Graduated', from: 'enrollment_role'
      check 'enrollment_overwrite'
    end
  end

  it 'can be performed using a list of IDs' do
    visit_new_enrollment_path
    submit_list_of_ids
    expect(page_has_enrollment_results(page)).to be_truthy
  end

  # rubocop:disable RSpec/AnyInstance
  it 'handles IDR timeout' do
    allow_any_instance_of(FakeProfileQuerier).to receive(:query)
      .and_raise(Rack::Timeout::RequestTimeoutException.new({}))
    visit_new_enrollment_path
    expect { submit_list_of_ids }.not_to raise_error
  end
  # rubocop:enable RSpec/AnyInstance

  def submit_list_of_ids
    list_of_ids = %w(id1 iD2 id3 ID3 invalidid).join(', ')
    fill_in 'enrollment_ids', with: list_of_ids
    click_on 'Submit'
  end

  def page_has_enrollment_results(page)
    page.assert_selector(:css, '.flash-error', text: /.+invalidid.+/) &&
      page.assert_selector(:css, '.flash-success', text: /.+id1.+id2.+id3.+/) &&
      page.assert_selector(:css, 'td')
  end

  def visit_new_enrollment_path
    visit root_path
    click_on 'Users'
    click_on 'Import Users'
  end
end
