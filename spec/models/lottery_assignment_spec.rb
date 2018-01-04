# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteryAssignment, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:lottery_assignment) }

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_numericality_of(:number) }
    it { is_expected.not_to allow_value(1.1).for(:number) }

    it { is_expected.to allow_value(false).for(:selected) }
    it { is_expected.to allow_value(true).for(:selected) }

    it { is_expected.to validate_presence_of(:draw) }
    it { is_expected.to belong_to(:draw) }

    it { is_expected.to have_many(:groups) }
  end

  describe 'factories' do
    it 'has a basic factory' do
      expect(FactoryGirl.build(:lottery_assignment)).to be_valid
    end
    it 'can be defined by a group' do
      group = FactoryGirl.create(:draw_in_lottery).groups.first
      lottery = FactoryGirl.build(:lottery_assignment, :defined_by_group,
                                  group: group)
      expect(lottery).to be_valid
    end
  end

  describe 'draw must be in lottery on create' do
    it do
      draw = FactoryGirl.create(:draw_in_lottery)
      lottery = FactoryGirl.build(:lottery_assignment, draw: draw)
      expect(lottery).to be_valid
    end
    it 'fails in other states' do
      draw = FactoryGirl.create(:draw_with_members, status: 'pre_lottery')
      group = FactoryGirl.create(:group, :defined_by_draw, draw: draw)
      lottery = FactoryGirl.build(:lottery_assignment, draw: draw,
                                                       groups: [group])
      expect(lottery).not_to be_valid
    end
  end

  it 'must have one group' do
    lottery = FactoryGirl.build(:lottery_assignment)
    lottery.groups = []
    expect(lottery).not_to be_valid
  end

  it 'number must be unique within a draw' do
    existing = FactoryGirl.create(:lottery_assignment)
    lottery = FactoryGirl.build(:lottery_assignment, draw: existing.draw,
                                                     number: existing.number)
    expect(lottery).not_to be_valid
  end

  it 'draw must match group draw' do
    groups = FactoryGirl.create(:draw_in_lottery).groups
    lottery = FactoryGirl.build(:lottery_assignment,
                                draw: FactoryGirl.create(:draw_in_lottery),
                                groups: groups)
    expect(lottery).not_to be_valid
  end

  describe 'frozen attributes' do
    it "can't change draw" do
      lottery = FactoryGirl.create(:lottery_assignment)
      draw = FactoryGirl.create(:draw_in_lottery)
      expect(lottery.update(draw: draw)).to be_falsey
    end
    it "can't change number after lottery phase is over" do
      lottery = FactoryGirl.create(:lottery_assignment)
      lottery.draw.suite_selection!
      expect(lottery.update(number: lottery.number + 1)).to be_falsey
    end
  end

  it 'can be destroyed' do
    lottery = FactoryGirl.create(:lottery_assignment)
    expect { lottery.destroy }.to change { LotteryAssignment.count }.by(-1)
  end

  describe '#update_selected!' do
    it 'updates selected to true when group has suite' do
      group = FactoryGirl.create(:group_with_suite)
      lottery = group.lottery_assignment
      lottery.update(selected: false)
      expect { lottery.update_selected! }.to \
        change { lottery.selected }.from(false).to(true)
    end
    it 'updates selected to false when group has no suite' do
      lottery = FactoryGirl.create(:lottery_assignment, selected: true)
      expect { lottery.update_selected! }.to \
        change { lottery.selected }.from(true).to(false)
    end
    it 'does nothing when selected matches the status' do
      lottery = FactoryGirl.create(:lottery_assignment)
      expect { lottery.update_selected! }.not_to change { lottery.selected }
    end
  end

  describe '#group' do
    context 'when single group' do
      it 'returns the group' do
        lottery = FactoryGirl.create(:lottery_assignment)
        expect(lottery.group).to eq(lottery.groups.first)
      end
    end
    # TODO: re-enable when we have clips
    # context 'when multiple groups' do
    #   it do
    #     lottery = FactoryGirl.create(:lottery_assignment)
    #     lottery.groups << FactoryGirl.create(:group, :defined_by_draw,
    #                                          draw: lottery.draw)
    #     expect(lottery.group).to eq(nil)
    #   end
    # end
  end
end
