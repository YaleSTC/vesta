# frozen_string_literal: true

require 'rails_helper'

describe UserUpdater do
  describe 'admins can edit themselves' do
    it 'returns the edited user object' do
      params = { email: 'newemail@email.com' }
      user = create_admin(params)
      updater = described_class.new(user: user, params: params,
                                    editing_self: true)
      expect(updater.update[:record][:email]).to eq('newemail@email.com')
    end
  end
  describe 'admins can edit others' do
    it 'can update the role' do
      params = { role: 'rep' }
      user = create_admin(params)
      updater = described_class.new(user: user, params: params,
                                    editing_self: false)
      expect(updater.update[:record][:role]).to eq('rep')
    end
  end

  describe 'failed update' do
    it 'returns an error if admins try to demote themselves' do
      params = { role: 'rep' }
      user = create_admin(params)
      updater = described_class.new(user: user, params: params,
                                    editing_self: true)
      expect(updater.update[:msg]).to have_key(:error)
    end
  end

  describe 'superusers and superadmins cannot have a college' do
    it 'returns an error for a superadmin' do
      params = { college_id: 1, role: 'superadmin' }
      user = create_admin(params)
      # both superusers and superadmins respond true to #superadmin?
      allow(user).to receive(:superadmin?).and_return(true)
      u = described_class.new(user: user, params: params, editing_self: false)
      expect(u.update[:msg]).to have_key(:error)
    end

    it 'allows for a college change for other roles' do
      params = { college_id: 1 }
      user = create_admin(params)
      u = described_class.new(user: user, params: params, editing_self: false)
      expect(u.update[:record][:college_id]).to eq(1)
    end
  end

  context 'warning flashes' do
    it 'appear if the user has a confirmed membership while changing college' do
      user = create(:full_group).members.last.reload
      params = { college_id: create(:college).id }
      u = described_class.new(user: user, params: params, editing_self: false)
      expect(u.update[:msg]).to have_key(:alert)
    end
    it 'do not appear if the user has not confirmed a membership' do
      # this creates a group of size 2
      user = create(:full_group).members.last.reload
      # unconfirm membership
      # rubocop:disable Rails/SkipsModelValidations
      user.memberships.first.update_column(:status, 'requested')
      # rubocop:enable Rails/SkipsModelValidations
      params = { college_id: create(:college).id }
      u = described_class.new(user: user, params: params, editing_self: false)
      expect(u.update[:msg]).not_to have_key(:alert)
    end
    it 'do not appear if the user is not changing colleges' do
      user = create(:locked_group, size: 2).members.last.reload
      params = { role: 'rep', college_id: user.college_id.to_s }
      u = described_class.new(user: user, params: params, editing_self: false)
      expect(u.update[:msg]).not_to have_key(:alert)
    end
  end

  context 'nullifying draw info' do
    let(:user) { create(:student_in_draw) }
    let(:membership) { instance_spy('Membership') }

    it 'destroys the group if the size is 1' do
      leader = create(:group).leader.reload
      allow(leader.group).to receive(:destroy!)
      params = { college_id: create(:college).id }
      described_class.update(user: leader, params: params, editing_self: false)
      expect(leader.group).to have_received(:destroy!)
    end

    it 'unlocks all memberships' do
      allow(user).to receive(:memberships).and_return([membership])
      params = { college_id: create(:college).id }
      described_class.update(user: user, params: params, editing_self: false)
      expect(membership).to have_received(:update_column).with(:locked, false)
    end

    it 'destroys all memberships' do
      allow(user).to receive(:memberships).and_return([membership])
      params = { college_id: create(:college).id }
      described_class.update(user: user, params: params, editing_self: false)
      expect(membership).to have_received(:destroy!)
    end

    it 'destroys all room assignments' do
      room_assignment = instance_spy('room_assignment', destroy!: true)
      allow(user).to receive(:room_assignment).and_return(room_assignment)
      params = { college_id: create(:college).id }
      described_class.update(user: user, params: params, editing_self: false)
      expect(room_assignment).to have_received(:destroy!)
    end

    it 'updates the draw id to nil' do
      params = { college_id: create(:college).id }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.draw_membership.draw_id).to eq(nil)
    end

    it 'updates the old draw id to nil' do
      params = { college_id: create(:college).id }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.draw_membership.old_draw_id).to eq(nil)
    end
  end

  context 'handling promotions and demotions' do
    it 'keeps the college_id if the role is not being changed' do
      user = create(:student_in_draw)
      params = { role: 'student' }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.college).to eq(College.current)
    end

    it 'keeps the college_id when promoting to non-superadmin role' do
      user = create(:student)
      params = { role: 'admin' }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.college).to eq(College.current)
    end

    it 'removes the college_id when promoting to superadmin' do
      user = create(:student)
      params = { role: 'superadmin' }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.college).to eq(nil)
    end

    it 'does not add a college_id when demoting from superuser to superadmin' do
      user = create(:admin, role: 'superuser', college: nil)
      params = { role: 'superadmin' }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.college).to eq(nil)
    end

    it 'adds a college_id when demoting to a non-superadmin role' do
      user = create(:admin, role: 'superuser', college: nil)
      params = { role: 'student' }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.college).to eq(College.current)
    end

    it 'keeps the college_id when demoting and a college_id is provided' do
      user = create(:admin, role: 'superuser', college: nil)
      params = { role: 'student', college_id: 1 }
      described_class.update(user: user, params: params, editing_self: false)
      expect(user.college_id).to eq(1)
    end
  end

  def create_admin(params)
    build_stubbed(:admin).tap do |user|
      response = user.assign_attributes(params)
      allow(user).to receive(:update!).with(params).and_return(response)
      allow(user).to receive(:admin?).and_return(true)
    end
  end
end
