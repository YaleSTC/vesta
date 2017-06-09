# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipDestroyer do
  describe '.destroy' do
    xit 'calls :destroy on an instance of MembershipDestroyer'
  end
  describe '#destroy' do
    it 'sucessfully destroys a membership' do
      m = instance_spy('Membership', destroy: true, user: instance_spy('User'))
      described_class.destroy(membership: m)
      expect(m).to have_received(:destroy)
    end
  end
end
