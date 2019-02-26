# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Drawless group routing' do
  let(:group) { create(:group) }
  let(:drawless_group) { create(:drawless_group) }

  context 'a permitted user' do
    before { log_in create(:admin) }

    it 'routes to group with draw' do
      visit group_path(group.id)
      expect(page).to have_link('Return to draw')
    end

    it 'navigates to group without draw' do
      visit group_path(drawless_group.id)
      expect(page).to have_link('View all special groups')
    end
  end
end
