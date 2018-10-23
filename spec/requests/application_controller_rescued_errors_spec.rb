# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Application Controller Rescued Errors', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  before do
    post user_session_path,
         params: { user: { email: user.email, password: 'passw0rd' } }
  end

  it 'raises error when user tries to access a restricted page' do
    get admin_user_path(admin)
    follow_redirect!
    expect(response.body)
      .to include('Sorry, you don&#39;t have permission to do that')
  end

  it 'raises error when a record could not be found' do
    get draw_path(id: 999)
    follow_redirect!
    expect(response.body).to include('Sorry, that record could not be found.')
  end
end
