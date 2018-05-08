# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipDestroyer do
  describe '#destroy' do
    it 'sucessfully destroys a membership' do
      m = instance_spy('Membership', destroy: true, locked?: false,
                                     user: instance_spy('User'))
      described_class.destroy(membership: m)
      expect(m).to have_received(:destroy)
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
