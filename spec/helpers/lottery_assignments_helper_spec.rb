# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteryAssignmentsHelper, type: :helper do
  describe '.lottery_form_id' do
    it 'returns a string with clip if clip_id is present' do
      lottery = instance_spy('lottery_assignment', clip_id: 1)
      expect(helper.lottery_form_id(lottery)).to eq('lottery-form-clip-1')
    end
    it 'returns a string with group if group is present' do
      group = instance_spy('group', id: 1, present?: true)
      lottery = instance_spy('lottery_assignment', group: group)
      expect(helper.lottery_form_id(lottery)).to eq('lottery-form-group-1')
    end
    it 'raises an ArgumentError if neither are present' do
      lottery = instance_spy('lottery_assignment')
      expect { helper.lottery_form_id(lottery) }.to raise_error(ArgumentError)
    end
  end

  describe '.lottery_owner_url' do
    it 'returns a url to the clip if clip_id is present' do
      lottery = instance_spy('lottery_assignment', clip_id: 1)
      expect(helper.lottery_owner_url(lottery)).to eq('/clips/1')
    end
    it 'returns a url to the group if a group is present' do
      draw = build_stubbed(:draw, id: 1)
      group = build_stubbed(:group, id: 1)
      lottery = instance_spy('lottery_assignment', draw: draw, group: group)
      expect(helper.lottery_owner_url(lottery)).to eq('/draws/1/groups/1')
    end
    it 'raises an ArgumentError if neither are present' do
      lottery = instance_spy('lottery_assignment')
      expect { helper.lottery_owner_url(lottery) }.to raise_error(ArgumentError)
    end
  end
end
