# frozen_string_literal: true

require 'rails_helper'

describe RoomUpdater do
  describe 'successful update' do
    it 'returns an array of the parent and the object' do
      building = instance_spy('Building')
      suite = instance_spy('Suite', building: building)
      room = instance_spy('Room', suite: suite, update: true)
      result = described_class.new(room: room, params: { number: 'L01' }).update
      expect(result[:redirect_object]).to eq([building, suite, room])
    end
  end
end
