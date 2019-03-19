# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawMembership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to belong_to(:user) }

    it do
      is_expected.to have_one(:led_group)
        .inverse_of(:leader_draw_membership)
        .with_foreign_key(:leader_draw_membership_id)
    end

    it { is_expected.to have_one(:membership) }
    it { is_expected.to have_one(:group).through(:membership) }
    it { is_expected.to have_many(:memberships) }
    it { is_expected.to have_one(:room_assignment) }
    it { is_expected.to have_one(:room).through(:room_assignment) }

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:intent) }
  end

  describe 'user uniqueness' do
    it 'is scoped to draw' do
      draw = create(:draw_with_members)
      user = draw.students.first
      draw_membership = described_class.new(draw: draw, user: user)
      expect(draw_membership).not_to be_valid
    end
    it 'allows for multiple drawless draw_memberships if others are inactive' do
      user = create(:user)
      create(:draw_membership, active: false, user: user, draw: nil)
      dm = create(:draw_membership, active: true, user: user, draw: nil)
      expect(dm).to be_valid
    end
  end

  describe 'validations' do
    it 'user cannot have multiple active draw memberships' do
      user = create(:student_in_draw)
      dm = build(:draw_membership, user: user, active: true)
      expect(dm).not_to be_valid
    end
    it 'user_id cannot be changed to a user with an active draw' do
      user = create(:student_in_draw)
      dm = create(:draw_membership, active: true)
      dm.user = user
      expect(dm).not_to be_valid
    end
  end

  describe '#remove_draw' do
    it 'backs up the current draw_id to old_draw_id' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234)
      result = dm.remove_draw
      expect(result.old_draw_id).to eq(123)
    end
    it 'removes the draw_id' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234)
      result = dm.remove_draw
      expect(result.draw_id).to be_nil
    end
    it 'changes the intent to undeclared' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234)
      result = dm.remove_draw
      expect(result.intent).to eq('undeclared')
    end
    it 'does not change old_draw_id if draw_id is nil' do
      dm = build_stubbed(:draw_membership, draw_id: nil, old_draw_id: 1234)
      result = dm.remove_draw
      expect(result).to eq(dm)
    end
  end

  describe '#restore_draw' do
    it 'copies old_draw_id to draw_id' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234)
      result = dm.restore_draw
      expect(result.draw_id).to eq(1234)
    end
    it 'sets draw_id to nil if old_draw_id and draw_id are equal' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 123)
      result = dm.restore_draw
      expect(result.draw_id).to be_nil
    end
    it 'sets old_draw_id to nil by default' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234)
      result = dm.restore_draw
      expect(result.old_draw_id).to be_nil
    end
    it 'optionally saves draw_id to old_draw_id' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234)
      result = dm.restore_draw(save_current: true)
      expect(result.old_draw_id).to eq(123)
    end
    it 'sets the intent to undeclared' do
      dm = build_stubbed(:draw_membership, draw_id: 123, old_draw_id: 1234,
                                           intent: 'on_campus')
      result = dm.restore_draw
      expect(result.intent).to eq('undeclared')
    end
  end
end
