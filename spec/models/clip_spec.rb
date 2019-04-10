# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clip, type: :model do
  describe 'basic validations' do
    it { is_expected.to have_many(:groups) }
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to have_one(:lottery_assignment).dependent(:nullify) }
    it { is_expected.to have_many(:clip_memberships).dependent(:delete_all) }
  end

  describe '#name' do
    it 'displays the name' do
      clip = create(:clip)
      expected = "#{clip.leader.full_name}'s Clip"
      expect(clip.name).to eq(expected)
    end
  end

  describe 'groups association' do
    it 'joins on confirmed memberships' do
      clip = create(:clip)
      group = create(:group_from_draw, draw: clip.draw)
      create(:clip_membership, clip: clip, group: group, confirmed: false)
      expect(clip.reload.groups.length).to eq(2)
    end
  end

  describe '#cleanup!' do
    it 'deletes the clip if there are not enough groups left' do
      clip = create(:clip, groups_count: 2)
      clip.clip_memberships.first.delete
      clip.reload.cleanup!
      expect { clip.reload } .to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'does nothing if there are more groups left' do
      clip = create(:clip, groups_count: 3)
      clip.clip_memberships.first.delete
      clip.reload.cleanup!
      expect(clip.reload).to eq(clip)
    end
  end

  describe '#leader' do
    it 'provides a leader' do
      draw = create(:draw)
      groups = create_pair(:group_from_draw, draw: draw)
      leader = groups.first.leader
      clip = create(:clip, groups: groups, draw: draw)
      expect(clip.leader).to eq(leader)
    end
    it 'provides the first unconfirmed leader if no confirmed groups exist' do
      clip = create(:clip)
      leader = clip.groups.first.leader
      clip.clip_memberships.each { |m| m.update!(confirmed: false) }
      expect(clip.leader).to eq(leader)
    end
  end

  describe '#size' do
    it 'counts the number of groups in the clip' do
      clip = create(:clip, groups_count: 3)
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
