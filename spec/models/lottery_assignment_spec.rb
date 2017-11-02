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

  describe 'group validations' do
    it 'must have at least one group' do
      lottery = build(:lottery_assignment, clip: nil)
      lottery.groups = []
      expect(lottery).not_to be_valid
    end
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
    expect { lottery.destroy }.to change { described_class.count }.by(-1)
  end

  it 'properly updates groups when created from a clip' do
    clip = create(:clip)
    clip.draw.lottery!
    lottery = described_class.create!(draw: clip.draw, clip: clip, number: 1,
                                      groups: clip.groups)
    expect(lottery.reload.groups).to match_array(clip.groups)
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

    context 'when multiple groups' do
      it do
        clip = create(:locked_clip)
        clip.draw.lottery!
        lottery = create(:lottery_assignment, :defined_by_clip, clip: clip)
        expect(lottery.group).to eq(nil)
      end
    end
  end

  describe '#leader' do
    it 'returns the clip leader when a clip is present' do
      clip = create(:locked_clip)
      clip.draw.lottery!
      lottery = create(:lottery_assignment, :defined_by_clip, clip: clip)
      expect(lottery.leader).to eq(clip.leader)
    end
    it "returns the first group's leader otherwise" do
      lottery = create(:lottery_assignment)
      expect(lottery.leader).to eq(lottery.groups.first.leader)
    end
  end

  describe '#name' do
    it 'returns the name of the leader with "clip" if for a clip' do
      clip = create(:locked_clip)
      clip.draw.lottery!
      lottery = create(:lottery_assignment, :defined_by_clip, clip: clip)
      expect(lottery.name).to eq(clip.leader.full_name + "'s clip")
    end
    it 'returns the name of the leader with "group" if not for a clip' do
      lottery = create(:lottery_assignment)
      expect(lottery.name).to eq(lottery.group.leader.full_name + "'s group")
    end
  end
end
