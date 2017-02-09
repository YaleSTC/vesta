# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupUpdater do
  it 'returns an array with the draw and the group' do
    draw = instance_spy('Draw')
    group = instance_spy('Group', draw: draw, update_attributes: true)
    params = instance_spy('ActionController::Parameters', to_h: {})
    updater = described_class.new(group: group, params: params)
    expect(updater.update[:object]).to eq([draw, group])
  end
  it 'returns the group object' do
    draw = instance_spy('Draw')
    group = instance_spy('Group', draw: draw, update_attributes: true)
    params = instance_spy('ActionController::Parameters', to_h: {})
    updater = described_class.new(group: group, params: params)
    expect(updater.update[:record]).to eq(group)
  end
end
