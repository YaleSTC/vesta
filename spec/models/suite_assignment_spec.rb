# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteAssignment, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:suite) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to validate_presence_of(:suite) }
    it { is_expected.to validate_presence_of(:group) }
  end

  describe 'validations' do
    it 'validates group uniqueness' do
      group = create(:suite_assignment).group
      s = SuiteAssignment.new(suite: create(:suite), group: group)
      expect(s).not_to be_valid
    end
  end

  context 'callbacks' do
    context 'on creation' do
      it 'calls update_selected! on the lottery assigned to the new group' do
        sa = build(:suite_assignment)
        stubbed_lottery = instance_spy('lottery_assignment', present?: true)
        allow(sa).to receive(:lottery_assignment).and_return(stubbed_lottery)
        sa.save
        expect(stubbed_lottery).to have_received(:update_selected!)
      end
    end

    context 'on destruction' do
      it 'calls update_selected! on the lottery assigned to the new group' do
        sa = create(:suite_assignment)
        stubbed_lottery = instance_spy('lottery_assignment', present?: true)
        allow(sa).to receive(:lottery_assignment).and_return(stubbed_lottery)
        sa.destroy!
        expect(stubbed_lottery).to have_received(:update_selected!)
      end
      it 'destroys room_assignments' do
        sa = create(:group_with_suite).suite_assignment
        ra = create(:room_assignment, user: sa.group.leader.reload,
                                      room: sa.suite.rooms.first)
        sa.destroy!
        expect { ra.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
