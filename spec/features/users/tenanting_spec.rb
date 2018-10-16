# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User Tenanting' do
  let(:host_url) { ENV.fetch('APPLICATION_HOST').gsub(/:\d+/, '') }
  let(:user) { create(:student) }
  let(:new_college) { create(:college) }

  it 'redirects all wrong tenant requests to APPLICATION_HOST/colleges' do
    # rails_helper normally starts in a tenant and we don't want that
    Apartment::Tenant.switch!('public')
    visit "http://wrongurl.#{host_url}"
    expect(current_url).to eq('http://' + host_url + '/colleges')
  end

  it 'redirects a student of another college back to their original college' do
    visit 'http://' + new_college.subdomain + '.' + host_url
    log_in user
    expected_url = 'http://' + user.college.subdomain + '.' + host_url + '/'
    expect(current_url).to eq(expected_url)
  end
end
