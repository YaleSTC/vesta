# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DrawCreator do
  context 'success' do
    it 'sucessfully creates a draw' do
      params = instance_spy('ActionController::Parameters',
                            to_h: FactoryGirl.attributes_for(:draw))
      expect(described_class.new(params).create![:object]).to \
        be_instance_of(Draw)
    end
    it 'returns a notice flash message' do
      params = instance_spy('ActionController::Parameters',
                            to_h: FactoryGirl.attributes_for(:draw))
      expect(described_class.new(params).create![:msg]).to have_key(:success)
    end
  end

  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: { name: nil })
    expect(described_class.new(params).create![:object]).to be_nil
  end
end
