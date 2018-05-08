# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'users' do
  it 'does not display superadmins or users in other colleges' do
    users = create_users
    log_in users[:shown].first
    visit users_path
    expect(page_has_valid_data(page, users)).to be_truthy
  end

  def create_users # rubocop:disable AbcSize
    users = { shown: [], unshown: [] }
    users[:shown] << create(:admin)
    users[:shown] << create(:student)
    users[:unshown] << create(:user, role: 'superadmin', college: nil)
    users[:unshown] << create(:user, role: 'superuser', college: nil)
    users[:unshown] << create(:student, college: create(:college))
    users
  end

  def page_has_valid_data(page, users)
    shown = users[:shown].all? do |u|
      expect(page).to have_css("tr#user-#{u.id}")
    end
    unshown = users[:unshown].all? do |u|
      expect(page).not_to have_css("tr#user-#{u.id}")
    end
    shown && unshown
  end
end
