# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RoomCreator do
  it 'sucessfully creates a room' do
    params_hash = { number: 'L01',
                    suite: FactoryGirl.build_stubbed(:suite) }
    params = instance_spy('ActionController::Parameters', to_h: params_hash)
    expect(described_class.new(params).create![:object]).to \
      be_instance_of(Room)
  end
  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:object]).to be_nil
  end
  it 'returns a notice flash message' do
    params_hash = { number: 'L01',
                    suite: FactoryGirl.build_stubbed(:suite) }
    params = instance_spy('ActionController::Parameters', to_h: params_hash)
    expect(described_class.new(params).create![:msg]).to have_key(:notice)
  end
end
