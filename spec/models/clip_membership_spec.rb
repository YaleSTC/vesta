# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:clip) }
  end

  describe 'group uniqueness' do
    it 'is scoped to clip' do
      clip = FactoryGirl.create(:clip)
      membership = ClipMembership.new(clip: clip, group: clip.groups.first)
      expect(membership).not_to be_valid
    end
  end

  it 'group can only have one accepted clip membership' do
    clip, other_clip = FactoryGirl.create_pair(:clip)
    m = ClipMembership.new(clip: other_clip, group: clip.groups.first)
    expect(m).not_to be_valid
  end

  it 'group draw and clip draw must match' do
    clip = FactoryGirl.create(:clip)
    group = FactoryGirl.create(:group)
    membership = FactoryGirl.build(:clip_membership, clip: clip, group: group)
    expect(membership).not_to be_valid
  end

  it 'cannot change clip' do
    clip = FactoryGirl.create(:clip)
    membership = clip.clip_memberships.last
    membership.clip = FactoryGirl.create(:clip, draw: clip.draw)
    expect(membership.save).to be_falsey
  end

  it 'cannot change group' do
    clip = FactoryGirl.create(:clip)
    membership = clip.clip_memberships.last
    membership.group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
    expect(membership.save).to be_falsey
  end

  it 'cannot remove clip' do
    clip = FactoryGirl.create(:clip)
    membership = clip.clip_memberships.last
    membership.clip_id = nil
    expect(membership.save).to be_falsey
  end

  it 'cannot remove group' do
    clip = FactoryGirl.create(:clip)
    membership = clip.clip_memberships.last
    membership.group_id = nil
    expect(membership.save).to be_falsey
  end

  it 'cannot change confirmation if not pre-lottery' do
    clip = FactoryGirl.create(:clip)
    clip.draw.update(status: 'draft')
    membership = clip.clip_memberships.last
    membership.confirmed = false
    expect(membership.save).to be_falsey
  end

  it 'can change confirmation if the draw is pre-lottery' do
    clip = FactoryGirl.create(:clip)
    clip.draw.update(status: 'pre_lottery')
    membership = clip.clip_memberships.last
    membership.confirmed = false
    expect(membership.save).to be_truthy
  end

  # rubocop:disable RSpec/ExampleLength
  describe 'pending clip membership destruction' do
    it 'on the group accepting another clip' do
      group = FactoryGirl.create(:locked_group)
      clip1, clip2 = FactoryGirl.create_pair(:clip, draw: group.draw)
      inv = create_membership(clip: clip1, group: group)
      req = create_membership(clip: clip2, group: group)
      inv.update(confirmed: true)
      expect { req.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end # rubocop:enable RSpec/ExampleLength

    def create_membership(clip:, group:, confirmed: false)
      FactoryGirl.create(:clip_membership, clip: clip, group: group,
                                           confirmed: confirmed)
    end
  end

  it 'runs clip#cleanup! after destruction' do
    clip = FactoryGirl.create(:clip)
    m = clip.clip_memberships.first
    allow(clip).to receive(:cleanup!)
    m.destroy!
    expect(clip).to have_received(:cleanup!)
  end
end
