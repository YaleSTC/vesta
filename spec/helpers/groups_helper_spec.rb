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
end
