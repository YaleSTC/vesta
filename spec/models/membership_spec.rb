# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'user uniqueness' do
    it 'is scoped to group' do
      user = FactoryGirl.create(:student_in_draw)
      group = FactoryGirl.create(:group, leader: user, draw: user.draw)
      membership = Membership.new(group: group, user: user)
      expect(membership).not_to be_valid
    end
  end

  describe 'user can only have one accepted membership' do
    it do # rubocop:disable RSpec/ExampleLength
      draw = FactoryGirl.create(:draw_with_members, students_count: 2)
      leader = draw.students.first
      FactoryGirl.create(:group, leader: leader)
      other_group = FactoryGirl.create(:open_group, leader: draw.students.last)
      m = Membership.new(user_id: leader.id, status: 'accepted',
                         group: other_group)
      expect(m).not_to be_valid
    end
  end

  describe 'group draw and user draw must match' do
    it do
      user = FactoryGirl.create(:student_in_draw)
      group = FactoryGirl.create(:open_group)
      membership = FactoryGirl.build(:membership, user: user, group: group)
      expect(membership.valid?).to be_falsey
    end
  end

  describe 'cannot change group' do
    it do
      group = FactoryGirl.create(:full_group)
      membership = group.memberships.last
      new_leader = FactoryGirl.create(:student, draw: group.draw)
      membership.group = FactoryGirl.create(:open_group, leader: new_leader)
      expect(membership.save).to be_falsey
    end
  end

  describe 'cannot change user' do
    it do
      group = FactoryGirl.create(:full_group)
      membership = group.memberships.last
      membership.user = FactoryGirl.create(:student, draw: group.draw)
      expect(membership.save).to be_falsey
    end
  end

  describe 'cannot change accepted status' do
    it do
      group = FactoryGirl.create(:full_group)
      membership = group.memberships.last
      membership.status = 'requested'
      expect(membership.save).to be_falsey
    end
  end

  context 'non-open group' do
    it 'cannot be created' do
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:student, draw: group.draw)
      allow(group).to receive(:open?).and_return(false)
      membership = FactoryGirl.build(:membership, user: user, group: group)
      expect(membership.valid?).to be_falsey
    end
  end

  describe 'updates the group status' do
    it 'updates to full on creation' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 2)
      draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
      group = FactoryGirl.create(:group, leader: draw.students.first, size: 2)
      expect { group.members << draw.students.last }.to \
        change { group.status }.from('open').to('full')
    end
    it 'updates to open on deletion' do
      group = FactoryGirl.create(:full_group, size: 2)
      expect { group.memberships.last.destroy }.to \
        change { group.status }.from('full').to('open')
    end
  end

  describe 'counter cache' do
    it 'increments on creation of accepted membership' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      expect { group.members << user }.to \
        change { group.memberships_count }.by(1)
    end
    # rubocop:disable RSpec/ExampleLength
    it 'increments on change to accepted status' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      membership = Membership.create(group: group, user: user,
                                     status: 'requested')
      expect { membership.update(status: 'accepted') }.to \
        change { group.memberships_count }.by(1)
    end
    # rubocop:enable RSpec/ExampleLength
    it 'does nothing on creation of request' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      expect do
        Membership.create(group: group, user: user, status: 'requested')
      end.not_to change { group.memberships_count }
    end
    it 'decrements on destruction of accepted membership' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      membership = Membership.create(group: group, user: user)
      expect { membership.destroy }.to change { group.memberships_count }.by(-1)
    end
    it 'does not decrement on destruction of request' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      membership = Membership.create(group: group, user: user,
                                     status: 'requested')
      expect { membership.destroy }.not_to change { group.memberships_count }
    end
  end

  context 'locked group' do
    it 'cannot be destroyed' do
      group = FactoryGirl.create(:full_group)
      group.update_attributes(status: 'locked')
      expect { group.memberships.first.destroy }.not_to \
        change { group.memberships_count }
    end
  end

  context 'user has not declared on_campus intent' do
    it 'cannot be created' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, draw: group.draw,
                                          intent: 'undeclared')
      membership = FactoryGirl.build(:membership, user: user, group: group)
      expect(membership.valid?).to be_falsey
    end
  end
end
