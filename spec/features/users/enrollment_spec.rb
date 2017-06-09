# frozen_string_literal: true

require 'rails_helper'
require 'support/fake_profile_querier'
require 'rack-timeout'

RSpec.feature 'User enrollment' do
  before do
    log_in(FactoryGirl.create(:admin))
    allow(ENV).to receive(:[]).and_return(nil)
    allow(ENV).to receive(:[]).with('QUERIER').and_return('FakeProfileQuerier')
  end

  it 'can be performed using a list of IDs' do
    visit new_enrollment_path
    submit_list_of_ids
    expect(page_has_enrollment_results(page)).to be_truthy
  end

  # rubocop:disable RSpec/AnyInstance
  it 'handles IDR timeout' do
    allow_any_instance_of(FakeProfileQuerier).to receive(:query)
      .and_raise(Rack::Timeout::RequestTimeoutException.new({}))
    visit new_enrollment_path
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
      page.assert_selector(:css, 'td', text: 'id1')
  end
end
