# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipDestroyer do
  describe '#destroy' do
    let(:m) { create(:full_group).memberships.last }

    it 'sucessfully destroys a membership' do
      allow(m).to receive(:destroy!)
      described_class.destroy(membership: m)
      expect(m).to have_received(:destroy!)
    end

    it 'unlocks all other memberships' do
      other_membership = instance_spy('membership', update!: true)
      allow(m.group).to receive(:memberships).and_return([m, other_membership])
      described_class.destroy(membership: m)
      expect(other_membership).to \
        have_received(:update!).with(locked: false)
    end
  end

  describe 'email callbacks' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

    it 'emails leader when someone leaves' do
      group = create(:full_group)
      m = group.memberships.last
      allow(StudentMailer).to receive(:left_group).and_return(msg)
      described_class.destroy(membership: m)
      expect(StudentMailer).to have_received(:left_group)
    end
  end

  describe 'validations' do
    it 'prevent locked memberships from being destroyed' do
      m = create(:locked_group).leader.memberships.first
      result = described_class.destroy(membership: m)
      expect(result[:msg][:error]).to \
        match(/cannot be destroyed if it is locked/)
    end
  end
end
