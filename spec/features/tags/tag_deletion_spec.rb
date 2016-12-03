# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Tag deletion' do
  before { log_in FactoryGirl.create(:admin) }
  let(:tag) { FactoryGirl.create(:tag) }

  it 'succeeds' do
    msg = "Tag #{tag.name} deleted."
    visit tag_path(tag)
    click_on 'Delete'
    expect(page).to have_content(msg)
  end
end
