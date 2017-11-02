# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembershipDestroyer do
  describe '#destroy' do
    it 'sucessfully destroys a clip membership' do
      m = instance_spy('ClipMembership', group: instance_spy('Group'))
      described_class.destroy(clip_membership: m)
      expect(m).to have_received(:destroy)
    end
    context 'success message' do
      it 'leaves clip' do
        m = instance_spy('ClipMembership', group: instance_spy('Group'),
                                           confirmed: true, destroy: true)
        result = described_class.destroy(clip_membership: m)[:msg][:notice]
        expect(result).to eq('Successfully left clip.')
      end
      it 'rejects invitation' do
        m = instance_spy('ClipMembership', group: instance_spy('Group'),
                                           confirmed: false, destroy: true)
        result = described_class.destroy(clip_membership: m)[:msg][:notice]
        expect(result).to eq('Successfully rejected invitation.')
      end
    end
  end
end
