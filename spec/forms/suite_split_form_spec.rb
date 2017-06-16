# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteSplitForm, type: :model do
  describe 'validations' do
    it 'validates suite presence' do
      params = mock_params({})
      object = described_class.new(suite: nil, params: params)
      expect(object).not_to be_valid
    end
    it 'validates that the suite has at least two rooms' do
      suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
      room = suite.rooms.first
      params = mock_params(room.id.to_s => 'foo')
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
    it 'validates that all rooms have a new suite assigned' do
      suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
      room = suite.rooms.first
      params = mock_params(room.id.to_s => 'foo')
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
  end

  describe '#submit' do
    let(:suite) { FactoryGirl.create(:suite_with_rooms, rooms_count: 2) }

    context 'success' do
      let(:params) { valid_params(suite) }

      it 'creates a new suite of the combined size' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:suites].length).to eq(2)
      end
      it 'deletes the original suite' do
        described_class.submit(suite: suite, params: params)
        expect(Suite.find_by(id: suite.id)).to be_nil
      end
      it 'assigns the suites to the correct building' do
        building_id = suite.building_id
        result = described_class.submit(suite: suite, params: params)
        expect(result[:suites].first.building_id).to eq(building_id)
      end
      it 'assigns the suites to the correct draws' do
        draw = FactoryGirl.create(:draw)
        suite.draws << draw
        result = described_class.submit(suite: suite, params: params)
        expect(result[:suites].first.draws).to eq([draw])
      end
      it 'assigns the rooms to the correct suite' do
        room = suite.rooms.first
        result = described_class.submit(suite: suite, params: params)
        expect(result[:suites].first.rooms).to match_array([room])
      end
      it 'sets :redirect_object to nil' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :form_object to nil' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:form_object]).to be_nil
      end
      it 'sets a success message' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:msg]).to have_key(:success)
      end
    end

    context 'failures' do
      let(:params) { mock_params({}) }

      it 'returns the original suite as the object' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:redirect_object]).to eq(suite)
      end
      it 'returns the form object' do
        object = described_class.new(suite: suite, params: params)
        expect(object.submit[:form_object]).to eq(object)
      end
      it 'sets :suites to nil' do
        object = described_class.new(suite: suite, params: params)
        expect(object.submit[:suites]).to be_nil
      end
      it 'sets an error message' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:msg]).to have_key(:error)
      end
      it 'fails if any update fails' do
        params = valid_params(suite)
        allow(Suite).to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(suite))
        result = described_class.submit(suite: suite, params: params)
        expect(result[:msg]).to have_key(:error)
      end
    end
  end

  def mock_params(hash)
    hash = hash.transform_keys { |k| "room_#{k}_suite" }
    instance_spy('ActionController::Parameters', to_h: hash)
  end

  def valid_params(suite)
    hash = suite.rooms.each_with_index.map { |r, i| [r.id.to_s, "SS#{i}"] }.to_h
    mock_params(hash)
  end
end
