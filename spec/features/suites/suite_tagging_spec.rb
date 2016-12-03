require 'rails_helper'

RSpec.feature 'Suite Tagging' do
  before { log_in FactoryGirl.create(:admin) }
  let(:suite) { FactoryGirl.create(:suite) }

  it 'can be tagged' do
    tag = FactoryGirl.create(:tag, name: 'Elevator Access')
    visit suite_path(suite)
    click_on 'Add Tag'
    select(tag.name, from: 'suite_tag_ids')
    click_on 'Add Tag'
    expect(page).to have_content('.suite-tags', text: tag.name)
  end

  it 'can be untagged' do
    suite.update_attributes(tags: [tag])
    click_on ".remove-#{tag.name.downcase}"
    expect(page).not_to have_content('.suite-tags', text: tag.name)
  end
end
