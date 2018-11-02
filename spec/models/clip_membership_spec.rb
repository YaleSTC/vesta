# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:clip) }
  end

  describe 'after acceptance' do
    it 'destroys all pending clip_memberships for the group' do
      membership = create(:clip_membership, confirmed: false)
      unconfirmed = create(:clip_membership, group: membership.group,
                                             confirmed: false)
      membership.update!(confirmed: true)
      expect { unconfirmed.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'clip membership cleanup' do
    let(:clip) { create(:clip) }
    let(:group) { create(:group) }
    let(:membership) { clip.clip_memberships.last }

    it 'runs clip#cleanup! after destruction' do
      m = clip.clip_memberships.first
      allow(clip).to receive(:cleanup!)
      m.destroy!
      expect(clip).to have_received(:cleanup!)
    end
  end
end
