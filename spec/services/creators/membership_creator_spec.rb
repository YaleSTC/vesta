# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MembershipCreator do
  describe '.create!' do
    it 'calls :create! on an instance of MembershipCreator' do
      params = instance_spy('Hash')
      membership_creator = mock_membership_creator(params)
      described_class.create!(params)
      expect(membership_creator).to have_received(:create!)
    end

    def mock_membership_creator(param_hash)
      instance_spy('MembershipCreator').tap do |mc|
        allow(described_class).to receive(:new).with(param_hash).and_return(mc)
      end
    end
  end

  context 'success' do
    it 'creates a membership object' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:membership]).to \
        be_instance_of(Membership)
    end
    it 'sets a success message in the flash' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:msg]).to have_key(:success)
    end
    # rubocop:disable RSpec/InstanceVariable
    def params_hash
      @group ||= FactoryGirl.create(:open_group)
      @user ||= FactoryGirl.build(:student, intent: 'on_campus',
                                            draw: @group.draw)
      { group: @group, user: @user, status: 'requested' }
    end
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:object]).to be_nil
  end
  it 'returns the membership even if invalid' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:membership]).to \
      be_instance_of(Membership)
  end
end
