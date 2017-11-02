# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnconfirmedClipMembershipsForDrawQuery do
  context 'correctly' do
    let(:clip) { create(:clip) }
    let(:draw) { clip.draw }
    let(:clip_membership) { clip.clip_memberships.last }

    before { clip_membership.update!(confirmed: false) }

    it 'returns unconfirmed clip_memberships in a draw' do
      clip_membership2 = create(:clip, draw: draw).clip_memberships.last
      clip_membership2.update!(confirmed: false)
      result = described_class.call(draw: draw)
      expect(result).to match_array([clip_membership, clip_membership2])
    end
    it 'does not return clip memberships from other draws' do
      create(:clip).clip_memberships.last.update(confirmed: false)
      result = described_class.call(draw: draw)
      expect(result).to eq([clip_membership])
    end
    it 'raises an error if no draw is provided' do
      expect { described_class.call } .to raise_error(ArgumentError)
    end
  end
end
