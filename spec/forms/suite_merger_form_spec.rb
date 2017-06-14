# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteMergerForm, type: :model do
  describe 'validations' do
    it 'requires a suite' do
      params = mock_params(other_suite_number: '1234', number: 'foo')
      allow(Suite).to receive(:find_by).and_return(instance_spy('Suite'))
      object = described_class.new(suite: nil, params: params)
      expect(object).not_to be_valid
    end
    it 'requires a number' do
      suite = FactoryGirl.build(:suite, number: nil)
      params = mock_params(other_suite_number: '1234', number: nil)
      allow(Suite).to receive(:find_by).and_return(instance_spy('Suite'))
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
    it 'requires a valid other_suite' do
      suite = FactoryGirl.build(:suite)
      params = mock_params(other_suite_number: '1234', number: 'foo')
      allow(Suite).to receive(:find_by).and_return(nil)
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
    it 'validates that both suites are different' do
      suite = FactoryGirl.build(:suite, id: 1234)
      params = mock_params(other_suite_number: '1234', number: 'foo')
      allow(Suite).to receive(:find_by).and_return(suite)
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
    it 'validates that both suites are in the same building' do
      suite, other_suite = FactoryGirl.build_pair(:suite)
      params = mock_params(other_suite_number: '1234', number: 'foo')
      allow(Suite).to receive(:find_by).and_return(other_suite)
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
    # rubocop:disable RSpec/ExampleLength
    it 'validates that the suite is available' do
      suite = FactoryGirl.build(:suite, group_id: 123, id: 123)
      other_suite = FactoryGirl.build(:suite, building: suite.building, id: 124)
      params = mock_params(other_suite_number: '124', number: 'foo')
      allow(Suite).to receive(:find_by).and_return(other_suite)
      object = described_class.new(suite: suite, params: params)
      expect(object).not_to be_valid
    end
    it 'validates that the other_suite is available' do
      suite = FactoryGirl.build(:suite, group_id: 123, id: 123)
      other_suite = FactoryGirl.build(:suite, building: suite.building, id: 124)
      params = mock_params(other_suite_number: '124', number: 'foo')
      allow(Suite).to receive(:find_by).and_return(suite)
      object = described_class.new(suite: other_suite, params: params)
      expect(object).not_to be_valid
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#submit' do
    let(:suite) { FactoryGirl.create(:suite_with_rooms) }

    context 'success' do
      let(:other_suite) do
        FactoryGirl.create(:suite_with_rooms, building: suite.building)
      end

      let(:params) do
        other = FactoryGirl.create(:suite_with_rooms, building: suite.building)
        mock_params(other_suite_number: other.number, number: 'foo')
      end

      it 'returns the new suite and building in :redirect_object' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:redirect_object].class).to eq(Suite)
      end
      it 'creates a new suite of the combined size' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:record].size).to eq(suite.size + other_suite.size)
      end
      it 'creates a new suite with the defined number' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:record].number).to eq('foo')
      end
      it 'creates a new suite with the correct building' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:record].building).to eq(suite.building)
      end
      it 'creates a new suite with the correct draw' do
        draw = FactoryGirl.create(:draw)
        draw.suites << suite
        result = described_class.submit(suite: suite, params: params)
        expect(result[:record].draws.map(&:id)).to include(draw.id)
      end
      # rubocop:disable RSpec/ExampleLength
      it 'calls :store_original_suite! on the rooms' do
        suite.rooms.each do |room|
          allow(room).to receive(:store_original_suite!)
            .with(any_args).and_return(room)
        end
        described_class.submit(suite: suite, params: params)
        expect(suite.rooms).to all(have_received(:store_original_suite!))
      end
      # rubocop:enable RSpec/ExampleLength
      it 'returns nil for :form_object' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:form_object]).to be_nil
      end
      it 'sets a success message' do
        result = described_class.submit(suite: suite, params: params)
        expect(result[:msg]).to have_key(:success)
      end
    end

    context 'failures' do
      it 'returns nil as the object' do
        params = mock_params(other_suite_number: nil)
        result = described_class.submit(suite: suite, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        params = mock_params(other_suite_number: nil)
        object = described_class.new(suite: suite, params: params)
        expect(object.submit[:form_object]).to eq(object)
      end
      it 'sets an error message' do
        params = mock_params(other_suite_number: nil)
        result = described_class.submit(suite: suite, params: params)
        expect(result[:msg]).to have_key(:error)
      end
      # rubocop:disable ExampleLength
      it 'fails if any update fails' do
        other_suite = FactoryGirl.create(:suite, building: suite.building)
        params = mock_params(other_suite_number: other_suite.number)
        allow(Suite).to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(other_suite))
        result = described_class.submit(suite: suite, params: params)
        expect(result[:msg]).to have_key(:error)
      end
      # rubocop:enable ExampleLength
    end
  end

  def mock_params(other_suite_number: nil, number: nil)
    hash = { other_suite_number: other_suite_number, number: number }
    instance_spy('ActionController::Parameters', to_h: hash)
  end
end
