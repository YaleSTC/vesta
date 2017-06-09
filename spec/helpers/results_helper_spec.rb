# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsHelper, type: :helper do
  describe '#room_occupants' do
    let(:occupants) { [instance_spy('user', full_name: 'John Doe')] }
    let(:room) { instance_spy('room', users: occupants) }

    it 'returns only student names if no transfers' do
      allow(room).to receive(:beds).and_return(1)
      expect(helper.room_occupants(room)).to eq('John Doe')
    end
    it 'returns only transfers pluralized if no students' do
      allow(room).to receive(:users).and_return([])
      allow(room).to receive(:beds).and_return(2)
      expect(helper.room_occupants(room)).to eq('2 transfers')
    end
    it 'returns the combined string when appropriate' do
      allow(room).to receive(:students)
        .and_return([FactoryGirl.build(:student)])
      allow(room).to receive(:beds).and_return(2)
      expect(helper.room_occupants(room)).to eq('John Doe, 1 transfer')
    end
  end
end
