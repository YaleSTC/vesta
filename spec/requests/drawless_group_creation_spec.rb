# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Special group creation', type: :request do
  let!(:leader) { create(:student, intent: 'on_campus') }
  let(:admin) { create(:admin) }

  before do
    create(:college)
    create(:suite_with_rooms, rooms_count: 1)
    post user_session_path,
         params: { user: { email: admin.email, password: 'passw0rd' } }
  end
  it 'sanitizes the transfers param' do
    post groups_path,
         params: { group: { size: 1, leader_id: leader.id, transfers: 1 } }
    follow_redirect!
    expect(response.body).not_to include('<h3 class="transfers">')
  end
end
