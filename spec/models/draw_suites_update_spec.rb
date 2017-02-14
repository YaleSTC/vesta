# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DrawSuitesUpdate do
  describe '.update' do
    xit 'calls :update on a new instance of DrawSuitesUpdate' do
    end
  end

  describe '#new' do
    it 'raises with an invalid size parameter' do
      draw = FactoryGirl.build_stubbed(:draw)
      params = instance_spy('ActionController::Parameters', to_h: { size: nil })
      expect { described_class.new(draw: draw, params: params) }.to \
        raise_error(ArgumentError)
    end
  end

  describe '#update' do
    context 'success' do
      it 'removes current suites of the correct size' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
        params = mock_params(suite_ids: [])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(-1)
      end
      it 'does not remove suites with groups' do
        draw = FactoryGirl.create(:draw)
        draw.suites << FactoryGirl.create(:suite_with_rooms, group_id: 123)
        params = mock_params(suite_ids: [])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(0)
      end
      # rubocop:disable RSpec/ExampleLength
      it 'adds suites from both drawn_suite_ids and undrawn_suite_ids' do
        draw = FactoryGirl.create(:draw)
        undrawn_suite = FactoryGirl.create(:suite)
        drawn_suite = create_drawn_suite
        params = mock_params(drawn_suite_ids: [drawn_suite.id.to_s],
                             undrawn_suite_ids: [undrawn_suite.id.to_s])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(2)
      end
      # rubocop:enable RSpec/ExampleLength
      it 'sets :object to nil' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        params = mock_params(suite_ids: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:object]).to be_nil
      end
      it 'sets :update_object to nil' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        params = mock_params(suite_ids: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:update_object]).to be_nil
      end
      it 'sets a success message' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        params = mock_params(suite_ids: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:msg]).to have_key(:success)
      end
    end

    context 'warning' do
      it 'sets :object to nil' do
        draw = FactoryGirl.create(:draw)
        result = described_class.update(draw: draw, params: mock_params)
        expect(result[:object]).to be_nil
      end
      it 'sets :update_object to the update object' do
        draw = FactoryGirl.create(:draw)
        update_object = described_class.new(draw: draw, params: mock_params)
        expect(update_object.update[:update_object]).to eq(update_object)
      end
      it 'sets an alert message' do
        draw = FactoryGirl.create(:draw)
        result = described_class.update(draw: draw, params: mock_params)
        expect(result[:msg]).to have_key(:alert)
      end
    end

    context 'error' do
      it 'sets :object to nil' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        allow(draw).to receive(:suites).and_return(broken_suites)
        params = mock_params(suite_ids: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:object]).to be_nil
      end
      it 'sets :update_object to the update object' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        allow(draw).to receive(:suites).and_return(broken_suites)
        params = mock_params(suite_ids: [])
        update_object = described_class.new(draw: draw, params: params)
        expect(update_object.update[:update_object]).to eq(update_object)
      end
      it 'sets an error message' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        allow(draw).to receive(:suites).and_return(broken_suites)
        params = mock_params(suite_ids: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:msg]).to have_key(:error)
      end

      def broken_suites # rubocop:disable AbcSize
        klass = 'Suite::ActiveRecord_Associations_CollectionProxy'
        instance_spy(klass).tap do |s|
          allow(s).to receive(:destroy).and_raise(ActiveRecord::RecordInvalid)
          # this is necessary to get through the #find_suites_to_remove private
          # method, which will ideally be refactored eventually
          allow(s).to receive(:where).and_return([Suite.last])
          allow(s).to receive(:available).and_return(s)
        end
      end
    end

    def mock_params(suite_ids: nil, drawn_suite_ids: nil,
                    undrawn_suite_ids: nil)
      # takes the default size from the factory :draw_with_members /
      # :suites_with_rooms
      hash = { suite_ids: suite_ids, drawn_suite_ids: drawn_suite_ids,
               undrawn_suite_ids: undrawn_suite_ids, size: '1' }
      instance_spy('ActionController::Parameters', to_h: hash)
    end

    def create_drawn_suite
      draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
      draw.suites.first
    end
  end
end
