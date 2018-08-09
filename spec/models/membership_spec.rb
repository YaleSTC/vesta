# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:draw_membership) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_one(:user).through(:draw_membership) }
    it { is_expected.to have_one(:draw).through(:draw_membership) }

    it { is_expected.to validate_presence_of(:draw_membership) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'user uniqueness' do
    it 'is scoped to group' do
      user = create(:student_in_draw)
      group = create(:group, leader: user, draw: user.draw)
      membership = described_class.new(group: group,
                                       draw_membership: user.draw_membership)
      expect(membership).not_to be_valid
    end
  end

  describe 'user can only have one accepted membership' do
    it do # rubocop:disable RSpec/ExampleLength
      draw = create(:draw_with_members, students_count: 2)
      leader = draw.students.first
      create(:group, leader: leader)
      other_group = create(:open_group, leader: draw.students.last)
      m = described_class.new(draw_membership: leader.draw_membership.reload,
                              status: 'accepted', group: other_group)
      expect(m).not_to be_valid
    end
  end

  describe 'group draw and user draw must match' do
    it do
      user = create(:student_in_draw)
      group = create(:open_group)
      membership = build(:membership, user: user, group: group)
      expect(membership.valid?).to be_falsey
    end
  end

  describe 'cannot change group' do
    let(:group) { create(:full_group) }
    let(:membership) { group.memberships.last }
    let(:msg) { 'Cannot change group or user associated with this membership' }

    it do
      new_leader = create(:student_in_draw, draw: group.draw)
      membership.group = create(:open_group, leader: new_leader)
      expect(membership.save).to be_falsey
    end
    it 'raises error if group changed' do
      new_leader = create(:student_in_draw, draw: group.draw)
      membership.update(group: create(:open_group, leader: new_leader))
      expect(membership.errors[:base]).to include(msg)
    end
  end

  describe 'cannot change draw_membership' do
    let(:group) { create(:full_group) }
    let(:msg) { 'Cannot change group or user associated with this membership' }

    it do
      membership = group.memberships.last
      membership.draw_membership = create(:draw_membership, draw: group.draw)
      expect(membership.save).to be_falsey
    end
    it 'raises error if user changed' do
      membership = group.memberships.last
      membership.draw_membership = create(:draw_membership, draw: group.draw)
      membership.save
      expect(membership.errors[:base]).to include(msg)
    end
  end

  describe 'cannot change accepted status' do
    let(:msg) { 'Cannot change membership status after acceptance' }

    it do
      group = create(:full_group)
      membership = group.memberships.last
      membership.status = 'requested'
      expect(membership.save).to be_falsey
    end
    it 'raises error if status changed' do
      group = create(:full_group)
      membership = group.memberships.last
      membership.status = 'requested'
      membership.save
      expect(membership.errors[:base]).to include(msg)
    end
  end

  context 'non-open group' do
    it 'cannot be created' do
      group = create(:finalizing_group)
      user = create(:student_in_draw, draw: group.draw)
      membership = build(:membership, user: user, group: group)
      expect(membership).not_to be_valid
    end
  end

  describe 'updates the group status' do
    it 'updates to full on creation' do # rubocop:disable RSpec/ExampleLength
      draw = create(:draw_with_members, students_count: 2)
      draw.suites << create(:suite_with_rooms, rooms_count: 2)
      group = create(:group, leader: draw.students.first, size: 2)
      expect do
        described_class.create!(draw_membership: draw.draw_memberships.last,
                                group: group)
      end.to \
        change { group.status }.from('open').to('closed')
    end
    it 'updates to open on deletion' do
      group = create(:full_group, size: 2)
      expect { group.memberships.last.destroy }.to \
        change { group.status }.from('closed').to('open')
    end
    it 'updates to locked when the last membership locks' do
      group = create(:full_group, size: 1)
      group.finalizing!
      expect { group.memberships.first.update(locked: true) }.to \
        change { group.locked? }.from(false).to(true)
    end
  end

  describe 'counter cache' do
    # rubocop:disable RSpec/ExampleLength
    it 'increments on creation of accepted membership' do
      group = create(:open_group)
      dm = create(:draw_membership, intent: 'on_campus', draw: group.draw)
      expect do
        described_class.create!(group: group, draw_membership: dm,
                                status: 'accepted')
      end.to \
        change { group.memberships_count }.by(1)
    end
    it 'increments on change to accepted status' do
      group = create(:open_group)
      dm = create(:draw_membership, intent: 'on_campus', draw: group.draw)
      membership = described_class.create!(group: group, draw_membership: dm,
                                           status: 'requested')
      expect { membership.update(status: 'accepted') }.to \
        change { group.memberships_count }.by(1)
    end
    it 'does nothing on creation of request' do
      group = create(:open_group)
      dm = create(:draw_membership, intent: 'on_campus', draw: group.draw)
      expect do
        described_class.create!(group: group, draw_membership: dm,
                                status: 'requested')
      end.not_to change { group.memberships_count }
    end
    # rubocop:enable RSpec/ExampleLength

    it 'decrements on destruction of accepted membership' do
      group = create(:open_group)
      dm = create(:draw_membership, intent: 'on_campus', draw: group.draw)
      membership = described_class.create!(group: group, draw_membership: dm)
      expect { membership.destroy }.to change { group.memberships_count }.by(-1)
    end
    it 'does not decrement on destruction of request' do
      group = create(:open_group)
      dm = create(:draw_membership, intent: 'on_campus', draw: group.draw)
      membership = described_class.create!(group: group, draw_membership: dm,
                                           status: 'requested')
      expect { membership.destroy }.not_to change { group.memberships_count }
    end
  end

  context 'locked membership' do
    it 'cannot be destroyed' do
      group = create(:finalizing_group)
      membership = group.memberships.first
      expect { membership.destroy }.not_to change { group.memberships_count }
    end
    it 'raises error if attempted destruction' do
      group = create(:finalizing_group)
      membership = group.memberships.first
      membership.destroy
      expect(membership.errors[:base])
        .to include('Cannot destroy locked membership')
    end
    it 'cannot be changed while locked' do
      group = create(:finalizing_group)
      membership = group.memberships.first
      membership.update(group_id: nil)
      expect(membership.errors[:base])
        .to include('Cannot edit locked membership')
    end
    it 'must be accepted' do # rubocop:disable RSpec/ExampleLength
      group = create(:finalizing_group)
      dm = create(:draw_membership, draw: group.draw)
      membership = described_class.new(group: group, draw_membership: dm,
                                       status: 'requested')
      membership.locked = true
      expect(membership).not_to be_valid
    end
    it 'must belong to a finalizing group' do
      group = create(:full_group)
      membership = group.memberships.first
      membership.locked = true
      expect(membership).not_to be_valid
    end
  end

  context 'user has not declared on_campus intent' do
    it 'cannot be created' do
      group = create(:open_group)
      user = create(:student_in_draw, draw: group.draw, intent: 'undeclared')
      membership = build(:membership, user: user, group: group)
      expect(membership).not_to be_valid
    end
  end

  describe 'pending membership destruction' do
    context 'on the user creating their own group' do
      it do # rubocop:disable RSpec/ExampleLength
        inv_group = create(:open_group, size: 2)
        u = create(:student_in_draw, draw: inv_group.draw)
        invite = described_class.create!(group: inv_group,
                                         draw_membership: u.draw_membership,
                                         status: 'invited')
        create(:group, leader: u)
        expect { invite.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    context 'on the user accepting another membership' do
      it do # rubocop:disable RSpec/ExampleLength
        inv_group = create(:open_group, size: 2)
        req_group = create_group_in_draw(inv_group.draw)
        u = create(:student_in_draw, draw: inv_group.draw)
        inv = described_class.create!(group: inv_group,
                                      draw_membership: u.draw_membership,
                                      status: 'invited')
        req = described_class.create!(group: req_group,
                                      draw_membership: u.draw_membership,
                                      status: 'requested')
        inv.update(status: 'accepted')
        expect { req.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      def create_group_in_draw(draw)
        l = create(:student_in_draw, draw: draw)
        create(:open_group, size: 2, leader: l)
      end
    end
  end

  it 'runs group#cleanup! after destruction' do
    group = create(:group)
    m = group.memberships.first
    allow(group).to receive(:cleanup!)
    m.destroy!
    expect(group).to have_received(:cleanup!)
  end
end
