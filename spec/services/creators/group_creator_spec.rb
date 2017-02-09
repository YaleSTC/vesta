# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupCreator do
  context 'success' do
    it 'sucessfully creates a group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:group]).to \
        be_instance_of(Group)
    end
    it 'returns a success flash message' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:msg]).to have_key(:success)
    end
    it 'sets :object to the draw and the new group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:object].map(&:class)).to \
        eq([Draw, Group])
    end
  end

  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:object]).to be_nil
  end
  it 'returns the group even if invalid' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:record]).to \
      be_instance_of(Group)
  end

  # rubocop:disable RSpec/InstanceVariable
  def params_hash
    @leader ||= FactoryGirl.create(:student_in_draw)
    { size: @leader.draw.suite_sizes.first, leader_id: @leader.id }
  end
  # rubocop:enable RSpec/InstanceVariable
end
