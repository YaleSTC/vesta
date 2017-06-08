# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:group) }

    it { is_expected.to validate_presence_of(:size) }
    it { is_expected.to allow_value(1).for(:size) }
    it { is_expected.not_to allow_value(0).for(:size) }
    it { is_expected.not_to allow_value(-1).for(:size) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to belong_to(:leader) }
    it { is_expected.to validate_presence_of(:leader) }
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to have_one(:suite) }
    it { is_expected.to have_many(:memberships) }
    it { is_expected.to have_many(:full_memberships) }
    it { is_expected.to have_many(:members).through(:full_memberships) }
    it { is_expected.not_to allow_value(-1).for(:memberships_count) }
    it { is_expected.to validate_presence_of(:transfers) }
    it { is_expected.not_to allow_value(-1).for(:transfers) }
    it { is_expected.to validate_numericality_of(:lottery_number) }
  end

  describe 'size validations' do
    context 'for regular groups' do
      it 'must be available in the draw' do
        group = FactoryGirl.build(:group)
        allow(group.draw).to receive(:open_suite_sizes).and_return([1])
        group.size = 2
        expect(group.valid?).to be_falsey
      end
      it 'only runs on changing size' do
        group = FactoryGirl.create(:full_group, size: 2)
        allow(group.draw).to receive(:open_suite_sizes).and_return([1])
        expect(group.valid?).to be_truthy
      end
    end
    context 'for drawless groups' do
      it 'must be an existing suite size' do
        group = FactoryGirl.build(:drawless_group)
        allow(SuiteSizesQuery).to receive(:call).and_return([1])
        group.size = 2
        expect(group).not_to be_valid
      end
    end
    it 'must not have more members than the size' do
      group = FactoryGirl.create(:full_group, size: 2)
      allow(group.draw).to receive(:suite_sizes).and_return([1, 2])
      group.size = 1
      expect(group.valid?).to be_falsey
    end
    it 'also validates during creation' do
      leader, student = FactoryGirl.create_pair(:student)
      group = described_class.new(size: 1, leader_id: leader.id,
                                  member_ids: [student.id])
      group.save
      expect(group.persisted?).to be_falsey
    end
    it 'takes transfers into account' do
      group = FactoryGirl.create(:open_group, size: 2, transfers: 1)
      expect(group).to be_full
    end
  end

  describe 'status validations' do
    it 'can only be locked if the number of members match the size' do
      group = FactoryGirl.build(:open_group)
      group.status = 'locked'
      expect(group.valid?).to be_falsey
    end
    it 'can only be locked if all memberships are locked' do
      # finalizing locks the leader only, not any of the members
      group = FactoryGirl.create(:finalizing_group, size: 2)
      group.status = 'locked'
      expect(group.valid?).to be_falsey
    end
    it 'cannot be full when there are less members than the size' do
      group = FactoryGirl.build(:open_group)
      group.status = 'full'
      expect(group.valid?).to be_falsey
    end
    it 'takes transfers into account' do
      group = FactoryGirl.create(:open_group, size: 2, transfers: 1)
      group.status = 'open'
      expect(group).not_to be_valid
    end
    it 'cannot be open when members match the size' do
      group = FactoryGirl.create(:full_group, size: 2)
      group.status = 'open'
      expect(group.valid?).to be_falsey
    end
  end

  it 'destroys dependent memberships on destruction' do
    group = FactoryGirl.create(:drawless_group)
    membership_ids = group.memberships.map(&:id)
    group.destroy
    expect { Membership.find(membership_ids) }.to \
      raise_error(ActiveRecord::RecordNotFound)
  end

  it 'clears suite assignments on destruction' do
    group = FactoryGirl.create(:locked_group)
    suite = FactoryGirl.create(:suite, group_id: group.id)
    expect { group.destroy }.to change { suite.reload.group }.to(nil)
  end

  it 'updates status when changing transfer students' do
    group = FactoryGirl.create(:open_group, size: 2)
    group.update(transfers: 1)
    expect(group.reload).to be_full
  end

  it 'removes member room ids when disbanding' do
    group = FactoryGirl.create(:locked_group, size: 1)
    suite = FactoryGirl.create(:suite_with_rooms, group_id: group.id)
    group.leader.update!(room_id: suite.rooms.first.id)
    expect { group.destroy! }.to \
      change { group.leader.reload.room_id }.from(suite.rooms.first.id).to(nil)
  end

  describe 'leader is included as a member' do
    it do
      group = FactoryGirl.create(:group)
      expect(group.members).to include(group.leader)
    end
  end

  describe '#name' do
    it "includes the leader's name" do
      leader = instance_spy('User', full_name: 'First Last')
      group = FactoryGirl.build_stubbed(:group)
      allow(group).to receive(:leader).and_return(leader)
      expect(group.name).to include(leader.full_name)
    end

    it "includes the leader's class year" do
      leader = instance_spy('User', full_name: 'First Last', class_year: 2017)
      group = FactoryGirl.build_stubbed(:group)
      allow(group).to receive(:leader).and_return(leader)
      expect(group.name).to include(leader.class_year.to_s)
    end
  end

  describe '#requests' do
    it 'returns an array of users who have requested to join' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(group: group, user: user, status: 'requested')
      expect(group.requests).to eq([user])
    end
  end

  describe '#invitations' do
    it 'returns an array of users who have been invited to join' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(group: group, user: user, status: 'invited')
      expect(group.invitations).to eq([user])
    end
  end

  describe '#pending_memberships' do
    let(:group) { FactoryGirl.create(:open_group) }

    it 'returns invitations but not accepted memberships' do
      user = FactoryGirl.create(:student, draw: group.draw, intent: 'on_campus')
      m = Membership.create(group: group, user: user, status: 'invited')
      expect(group.pending_memberships).to match([m])
    end
    it 'returns requests but not accepted memberships' do
      user = FactoryGirl.create(:student, draw: group.draw, intent: 'on_campus')
      m = Membership.create(group: group, user: user, status: 'requested')
      expect(group.pending_memberships).to match([m])
    end
  end

  describe '#members' do
    it 'returns only members with an accepted membership' do
      group = FactoryGirl.create(:open_group)
      create_potential_member(status: 'invited', group: group)
      create_potential_member(status: 'requested', group: group)
      expect(group.reload.members.map(&:id)).to eq([group.leader.id])
    end

    def create_potential_member(status:, group:)
      u = FactoryGirl.create(:student, draw: group.draw, intent: 'on_campus')
      Membership.create(user: u, group: group, status: status)
      u
    end
  end

  describe '#removable_members' do
    it 'returns all accepted members except for the leader' do
      group = FactoryGirl.create(:full_group, size: 2)
      expect(group.removable_members.map(&:id)).not_to include(group.leader_id)
    end
  end

  describe '#remove_members!' do
    it 'removes members except leader' do
      group = FactoryGirl.create(:full_group, size: 3)
      ids = group.members.map(&:id)
      expect { group.remove_members!(ids: ids) }.to \
        change { group.memberships_count }.from(3).to(1)
    end
    it 'changes the group status from full to open' do
      group = FactoryGirl.create(:full_group, size: 2)
      ids = group.members.map(&:id)
      expect { group.remove_members!(ids: ids) }.to \
        change { group.status }.from('full').to('open')
    end
    it 'deletes membership object' do
      group = FactoryGirl.create(:full_group, size: 2)
      last_membership_id = group.memberships.last.id
      group.remove_members!(ids: [group.members.last.id])
      expect { Membership.find(last_membership_id) }.to \
        raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#destroy' do
    it 'restores members to their original draws if drawless' do
      group = FactoryGirl.create(:drawless_group)
      allow(group.leader).to receive(:restore_draw)
        .and_return(instance_spy('user', save: true))
      group.destroy
      expect(group.leader).to have_received(:restore_draw)
    end
    it 'does nothing if group belongs to a draw' do
      group = FactoryGirl.create(:group)
      allow(group.leader).to receive(:restore_draw)
      group.destroy
      expect(group.leader).not_to have_received(:restore_draw)
    end
  end

  describe '#locked_members' do
    it 'returns memberships that are locked' do
      group = FactoryGirl.create(:finalizing_group)
      expect(group.locked_members).to eq([group.leader])
    end
  end

  describe '#lockable?' do
    it 'returns true when all members are locked, and group is full' do
      group = FactoryGirl.create(:finalizing_group)
      group.full_memberships.reject(&:locked).each do |m|
        m.update(locked: true)
      end
      expect(group.reload).to be_lockable
    end
  end

  describe '#unlockable?' do
    it 'returns true when there are _any_ locked members and no suite' do
      group = FactoryGirl.create(:finalizing_group)
      group.update!(status: 'full')
      expect(group.reload).to be_unlockable
    end
    it 'returns false if the group has a suite assigned' do
      group = FactoryGirl.create(:locked_group)
      allow(group).to receive(:suite)
        .and_return(instance_spy('suite', nil?: false))
      expect(group).not_to be_unlockable
    end
    it 'returns false if there are no locked members' do
      group = FactoryGirl.create(:open_group)
      expect(group).not_to be_unlockable
    end
  end

  context 'on disbanding' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

    it 'notifies members' do
      group = FactoryGirl.create(:full_group)
      allow(StudentMailer).to receive(:disband_notification).and_return(msg)
      group.destroy
      expect(StudentMailer).to \
        have_received(:disband_notification).exactly(group.memberships_count)
    end
  end

  context 'on locking' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

    it 'notifies members' do
      group = FactoryGirl.create(:finalizing_group, size: 2)
      allow(StudentMailer).to receive(:group_locked).and_return(msg)
      group.memberships.last.update(locked: true)
      expect(StudentMailer).to \
        have_received(:group_locked).exactly(group.memberships_count)
    end
  end
end
