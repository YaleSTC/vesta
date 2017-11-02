# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsHelper, type: :helper do
  context '#member_str' do
    let(:membership) { instance_spy('membership') }
    let(:member) { instance_spy('user', id: 123, full_name: 'First Last') }
    let(:group) { mock_group(member, membership) }

    it 'returns the full name with an unlocked membership' do
      allow(membership).to receive(:locked?).and_return(false)
      expect(helper.member_str(member, group)).to match(member.full_name)
    end

    it 'returns the full name and notes a locked membership' do
      allow(membership).to receive(:locked?).and_return(true)
      expect(helper.member_str(member, group)).to \
        match(/#{member.full_name}.*(locked)/)
    end

    it 'returns the full name and notes a leader membership' do
      allow(group).to receive(:leader).and_return(member)
      allow(membership).to receive(:locked?).and_return(true)
      expect(helper.member_str(member, group)).to \
        match(/#{member.full_name}.*(leader)/)
    end

    def mock_group(member, membership)
      instance_spy('group').tap do |group|
        allow(group).to receive(:memberships).and_return(group)
        allow(group).to receive(:find_by).with(user_id: member.id)
                                         .and_return(membership)
      end
    end
  end

  context '#sort_by_lottery' do
    let(:group1) { instance_spy('group', lottery_number: 2) }
    let(:leader1) { instance_spy('user', last_name: 'Foo') }
    let(:group2) { instance_spy('group', lottery_number: nil, leader: leader1) }
    let(:leader2) { instance_spy('user', last_name: 'Bar') }
    let(:group3) { instance_spy('group', lottery_number: nil, leader: leader2) }
    let(:group4) { instance_spy('group', lottery_number: 1) }
    let!(:groups) { [group1, group2, group3, group4] }

    it 'sorts groups by lottery number (nil first) then leader last name' do
      expect(helper.sort_by_lottery(groups)).to \
        match_array([group3, group2, group4, group1])
    end
  end

  context '#display_group_status' do
    it 'returns the capitalization of a given status' do
      group = instance_spy('group', closed?: false, status: 'open',
                                    finalizing?: false)
      expect(helper.display_group_status(group)).to eq(group.status.capitalize)
    end

    it 'returns "Full" when status is "closed"' do
      group = instance_spy('group', closed?: true)
      expect(helper.display_group_status(group)).to eq('Full')
    end

    it 'returns "Locking" when status is "finalizing"' do
      group = instance_spy('group', closed?: false, finalizing?: true)
      expect(helper.display_group_status(group)).to eq('Locking')
    end
  end

  context '#clipping_name' do
    let(:group) { instance_spy('group', name: 'Test') }

    it "appends ' (confirmed)' when a clip is present" do
      clip = instance_spy('clip', present?: true)
      allow(group).to receive(:clip).and_return(clip)
      expect(helper.clipping_name(group)).to eq('Test (confirmed)')
    end

    it "appends ' (invited to clip)' when an invite exists" do
      clip_membership = instance_spy('clip_membership', present?: true)
      allow(group).to receive(:clip).and_return(nil)
      allow(group).to receive(:clip_memberships).and_return(clip_membership)
      expect(helper.clipping_name(group)).to eq('Test (invited to clip)')
    end

    it 'appends nothing if no clip info exists' do
      allow(group).to receive(:clip).and_return(nil)
      allow(group).to receive(:clip_membership).and_return(nil)
      expect(helper.clipping_name(group)).to eq(group.name)
    end
  end
end
