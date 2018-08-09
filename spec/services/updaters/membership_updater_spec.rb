# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipUpdater do
  let(:group) { instance_spy('Group', draw: instance_spy('Draw')) }
  let(:membership) do
    instance_spy('Membership', group: group, update_attributes: true,
                               user: instance_spy('User', full_name: 'Name'))
  end
  let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

  before { allow(StudentMailer).to receive(:joined_group).and_return(msg) }

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

  describe 'email callbacks' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }
    let(:g) { create(:open_group) }

    it 'emails leader on invitation acceptance' do
      m = create(:membership, group: g, status: 'invited')
      allow(StudentMailer).to receive(:joined_group).and_return(msg)
      described_class.update(membership: m, action: 'accept')
      expect(StudentMailer).to have_received(:joined_group)
    end

    it 'does not email leaders on request acceptance' do
      m = create(:membership, group: g, status: 'requested')

      allow(StudentMailer).to receive(:joined_group).and_return(msg)
      described_class.update(membership: m, action: 'accept')
      expect(StudentMailer).not_to have_received(:joined_group)
    end
  end
end
