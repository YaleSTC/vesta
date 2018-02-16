# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clip, type: :model do
  describe 'basic validations' do
    it { is_expected.to have_many(:groups) }
    it { is_expected.to belong_to(:draw) }
  end

  describe 'validations' do
    it 'prevent non-clipping draws from making clips' do
      draw = create(:draw, allow_clipping: false)
      clip = build(:clip, draw: draw)
      expect(clip.valid?).to be_falsey
    end
  end

  describe '#name' do
    it 'displays the name' do
      clip = FactoryGirl.create(:clip)
      expected = "#{clip.leader.full_name}'s Clip"
      expect(clip.name).to eq(expected)
    end
  end

  describe 'groups association' do
    it 'joins on confirmed memberships' do
      clip = FactoryGirl.create(:clip)
      group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
      FactoryGirl.create(:clip_membership, clip: clip, group: group,
                                           confirmed: false)
      expect(clip.reload.groups.length).to eq(2)
    end
  end

  describe '#cleanup!' do
    it 'deletes the clip if there are not enough groups left' do
      clip = FactoryGirl.create(:clip, groups_count: 2)
      clip.clip_memberships.first.delete
      clip.reload.cleanup!
      expect { clip.reload } .to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'does nothing if there are more groups left' do
      clip = FactoryGirl.create(:clip, groups_count: 3)
      clip.clip_memberships.first.delete
      clip.reload.cleanup!
      expect(clip.reload).to eq(clip)
    end
    it 'all clip_memberships are deleted on clip destruction' do
      clip = FactoryGirl.create(:clip)
      clip_memberships = clip.clip_memberships
      clip.destroy!
      expect(clip_memberships).to eq([])
    end
  end

  describe '#leader' do
    it 'provides a leader' do
      draw = FactoryGirl.create(:draw)
      groups = FactoryGirl.create_pair(:group_from_draw, draw: draw)
      leader = groups.first.leader
      clip = FactoryGirl.create(:clip, groups: groups, draw: draw)
      expect(clip.leader).to eq(leader)
    end
    it 'provides the first unconfirmed leader if no confirmed groups exist' do
      clip = FactoryGirl.create(:clip)
      leader = clip.groups.first.leader
      clip.clip_memberships.each { |m| m.update!(confirmed: false) }
      expect(clip.leader).to eq(leader)
    end
  end

  describe '#size' do
    it 'counts the number of groups in the clip' do
      clip = FactoryGirl.create(:clip, groups_count: 3)
      clip.clip_memberships.last.update!(confirmed: false)
      expect(clip.size).to eq(2)
    end
  end

  def build_groups(count:, **overrides)
    group_params = Array.new(count) do |i|
      { name: "group#{i}", lottery_number: i + 1, draw_id: i + 1 }
        .merge(**overrides)
    end
    group_params.map { |p| instance_spy('group', **p) }
  end
end
