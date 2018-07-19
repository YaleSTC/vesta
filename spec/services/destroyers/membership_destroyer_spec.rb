# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipDestroyer do
  describe '.destroy' do
    xit 'calls :destroy on an instance of MembershipDestroyer'
  end
  describe '#destroy' do
    it 'sucessfully destroys a membership' do
      m = instance_spy('Membership', destroy: true, user: instance_spy('User'))
      allow(m).to receive(:destroy)
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
end
