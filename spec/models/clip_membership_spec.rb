# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:clip) }
  end
  let(:clip) { create(:clip) }
  let(:group) { create(:group) }
  let(:membership) { clip.clip_memberships.last }

  describe 'group uniqueness' do
    it 'is scoped to clip' do
      membership = ClipMembership.new(clip: clip, group: group)
      expect(membership).not_to be_valid
    end
    it 'group can only have one accepted clip membership' do
      other_clip = create(:clip)
      m = ClipMembership.new(clip: other_clip, group: clip.groups.first)
      expect(m).not_to be_valid
    end
    it 'group draw and clip draw must match' do
      membership = build(:clip_membership, clip: clip, group: group)
      expect(membership).not_to be_valid
    end
  end

  describe 'freeze clip before update' do
    it 'cannot change clip' do
      membership.clip = create(:clip, draw: clip.draw)
      expect(membership.save).to be_falsey
    end
    it 'cannot remove clip' do
      membership.clip_id = nil
      expect(membership.save).to be_falsey
    end
    it 'returns error if clip is updated' do
      membership.clip = create(:clip, draw: clip.draw)
      membership.save
      expect(membership.errors[:base])
        .to include('Cannot change clip inside clip membership')
    end
  end

  describe 'freeze group before update' do
    it 'cannot change group' do
      membership.group = create(:group_from_draw, draw: clip.draw)
      expect(membership.save).to be_falsey
    end
    it 'cannot remove group' do
      membership.group_id = nil
      expect(membership.save).to be_falsey
    end
    it 'returns error if group is updated' do
      membership.group = create(:group_from_draw, draw: clip.draw)
      membership.save
      expect(membership.errors[:base])
        .to include('Cannot change group inside clip membership')
    end
  end

  describe 'freeze confirm unless group-formation' do
    let(:msg) do
      'Cannot confirm clip membership outside of group-formation phase'
    end

    it 'cannot change confirmation if not group-formation' do
      clip.draw.update(status: 'draft')
      membership.confirmed = false
      expect(membership.save).to be_falsey
    end
    it 'can change confirmation if the draw is group-formation' do
      clip.draw.update(status: 'group_formation')
      membership.confirmed = false
      expect(membership.save).to be_truthy
    end
    it 'returns error if confirmation changed in not group-formation' do
      clip.draw.update(status: 'draft')
      membership.confirmed = false
      membership.save
      expect(membership.errors[:base])
        .to include(msg)
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe 'pending clip membership destruction' do
    it 'on the group accepting another clip' do
      group = create(:locked_group)
      clip1, clip2 = create_pair(:clip, draw: group.draw)
      inv = create_membership(clip: clip1, group: group)
      req = create_membership(clip: clip2, group: group)
      inv.update(confirmed: true)
      expect { req.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end # rubocop:enable RSpec/ExampleLength

    def create_membership(clip:, group:, confirmed: false)
      create(:clip_membership, clip: clip, group: group, confirmed: confirmed)
    end
  end

  describe 'clip membership cleanup' do
    it 'runs clip#cleanup! after destruction' do
      m = clip.clip_memberships.first
      allow(clip).to receive(:cleanup!)
      m.destroy!
      expect(clip).to have_received(:cleanup!)
    end
  end
end
