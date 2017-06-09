# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw status' do
  let(:draw) { FactoryGirl.create(:draw) }

  it 'displays intent metrics' do
    metrics = { 'off_campus' => 0, 'on_campus' => 2, 'undeclared' => 1 }
    create_intent_data(draw, metrics)

    log_in(FactoryGirl.create(:user))
    visit draw_path(draw)

    expect(page_has_intent_metrics(page, metrics))
  end

  def create_intent_data(draw, metrics)
    metrics.each do |status, count|
      FactoryGirl.create_list(:user, count, draw: draw, intent: status)
    end
  end

  def page_has_intent_metrics(page, metrics)
    metrics.all? do |status, count|
      page.has_css?(".#{status}-count", text: count.to_s)
    end
  end
end
