# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipUpdater do
  let(:group) { instance_spy('Group', draw: instance_spy('Draw')) }
  let(:membership) do
    instance_spy('Membership', group: group, update_attributes: true,
                               user: instance_spy('User', full_name: 'Name'))
  end

  it 'returns an array with the draw and the group from the membership' do
    updater = described_class.new(membership: membership, action: 'finalize')
    expect(updater.update[:redirect_object]).to eq([group.draw, group])
  end

  it 'finalizes a membership when given a finalize action' do
    updater = described_class.new(membership: membership, action: 'finalize')
    updater.update
    expect(membership).to have_received(:update!).with(locked: true)
  end

  it 'accepts a membership when given an accept action' do
    updater = described_class.new(membership: membership, action: 'accept')
    updater.update
    expect(membership).to have_received(:update!).with(status: 'accepted')
  end

  it 'is invalid if given the wrong action' do
    updater = described_class.new(membership: membership, action: 'foo')
    expect(updater).not_to be_valid
  end

  def mock_membership_updater(param_hash)
    instance_spy('MembershipUpdater').tap do |mu|
      allow(described_class).to receive(:new).with(param_hash).and_return(mu)
    end
  end
end
