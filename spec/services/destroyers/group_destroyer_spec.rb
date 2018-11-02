# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupDestroyer do
  it 'sucessfully destroys a group' do
    group = create(:full_group)
    destroyer = described_class.new(group: group)
    expect(destroyer.destroy[:redirect_object]).to be_nil
  end
  it 'fails if destroy fails' do
    g = instance_spy('Group', members: [])
    allow(g).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
    destroyer = described_class.new(group: g)
    expect(destroyer.destroy[:redirect_object]).to eq(g)
  end
  context 'on disbanding' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }
    let(:group) { create(:full_group) }

    it 'notifies members' do
      allow(StudentMailer).to receive(:disband_notification).and_return(msg)
      destroyer = described_class.new(group: group)
      destroyer.destroy
      expect(StudentMailer).to \
        have_received(:disband_notification).exactly(group.memberships_count)
    end
  end

  context 'actions while disbanding' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

    it 'removes member room ids when disbanding' do
      allow(StudentMailer).to receive(:disband_notification).and_return(msg)
      stub_room_assignment = make_stub_room_assignment
      group = make_stub_group(stub_room_assignment)
      described_class.new(group: group).destroy
      expect(stub_room_assignment).to have_received(:destroy!)
    end

    it 'raises an error if cannot remove room id' do
      allow(StudentMailer).to receive(:disband_notification).and_return(msg)
      stub_room_assignment = make_stub_room_assignment(false)
      group = make_stub_group(stub_room_assignment)
      result = described_class.new(group: group).destroy
      expect(result[:redirect_object]).to eq(group)
    end

    it 'restores members to their original draws if drawless' do
      group = create(:drawless_group)
      allow(group.leader).to receive(:restore_draw)
        .and_return(instance_spy('user', save: true))
      described_class.new(group: group).destroy
      expect(group.leader).to have_received(:restore_draw)
    end

    it 'does nothing if group belongs to a draw' do
      group = create(:group)
      allow(group.leader).to receive(:restore_draw)
      described_class.new(group: group).destroy
      expect(group.leader).not_to have_received(:restore_draw)
    end

    it 'raises an error if cannot restore the draw' do
      group = create(:drawless_group)
      allow(group.leader).to receive(:restore_draw)
        .and_raise(ActiveRecord::RecordInvalid)
      result = described_class.new(group: group).destroy
      expect(result[:redirect_object]).to eq(group)
    end
  end

  def make_stub_room_assignment(valid = false)
    stub_room_assignment = instance_spy('Room Assignment')
    if valid
      allow(stub_room_assignment).to receive(:destroy!).and_return(true)
    else
      allow(stub_room_assignment).to receive(:destroy!)
        .and_raise(ActiveRecord::RecordNotDestroyed)
    end
    allow(stub_room_assignment).to receive(:present?).and_return(true)

    stub_room_assignment
  end

  def make_stub_group(stub_room_assignment)
    user_ingroup = instance_spy('User', room_assignment: stub_room_assignment)
    group = instance_spy('Group', members: [user_ingroup])
    group
  end
end
