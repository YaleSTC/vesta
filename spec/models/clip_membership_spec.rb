# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:clip) }
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
