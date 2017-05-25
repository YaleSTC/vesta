# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawSuitesUpdate do
  describe '.update' do
    xit 'calls :update on a new instance of DrawSuitesUpdate' do
    end
  end

  describe '#update' do
    context 'success' do
      it 'removes current suites of all sizes' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
        params = mock_params(suite_ids_1: [])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(-2)
      end
      it 'does not remove suites with groups' do
        draw = FactoryGirl.create(:draw)
        draw.suites << FactoryGirl.create(:suite_with_rooms, group_id: 123)
        params = mock_params(suite_ids_1: [])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(0)
      end
      # rubocop:disable RSpec/ExampleLength
      it 'adds suites from both drawn_ids and drawless_ids' do
        draw = FactoryGirl.create(:draw)
        drawless_suite = FactoryGirl.create(:suite)
        drawn_suite = create_drawn_suite
        params = mock_params(drawn_ids_1: [drawn_suite.id.to_s],
                             drawless_ids_1: [drawless_suite.id.to_s])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(2)
      end
      it 'handles multiple suite sizes' do
        draw = FactoryGirl.create(:draw)
        drawless1 = FactoryGirl.create(:suite)
        drawless2 = FactoryGirl.create(:suite)
        params = mock_params(drawless_ids_1: [drawless1.id.to_s],
                             drawless_ids_2: [drawless2.id.to_s])
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.suites.count }.by(2)
      end
      # rubocop:enable RSpec/ExampleLength
      it 'sets :redirect_object to nil' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        params = mock_params(suite_ids_1: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object to nil' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        params = mock_params(suite_ids_1: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:update_object]).to be_nil
      end
      it 'sets a success message' do
        draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
        params = mock_params(suite_ids_1: [])
        result = described_class.update(draw: draw, params: params)
        expect(result[:msg]).to have_key(:success)
      end
    end

    context 'warning' do
      it 'sets :redirect_object to nil' do
        draw = FactoryGirl.create(:draw)
        result = described_class.update(draw: draw, params: mock_params)
        expect(result[:redirect_object]).to be_nil
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
      let(:draw) { FactoryGirl.create(:draw_with_members, suites_count: 1) }
      let(:params) { mock_params(suite_ids_1: []) }

      before do
        # necessary to prevent spy error due to available not being implemented
        draw.suites.available
        allow(draw).to receive(:suites).and_return(broken_suites)
      end

      it 'sets :redirect_object to nil' do
        result = described_class.update(draw: draw, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object to the update object' do
        update_object = described_class.new(draw: draw, params: params)
        expect(update_object.update[:update_object]).to eq(update_object)
      end
      it 'sets an error message' do
        result = described_class.update(draw: draw, params: params)
        expect(result[:msg]).to have_key(:error)
      end

      def broken_suites
        klass = 'Suite::ActiveRecord_Associations_CollectionProxy'
        instance_spy(klass).tap do |s|
          allow(s).to receive(:destroy).and_raise(ActiveRecord::RecordInvalid)
          # this is necessary to get through the #find_suites_to_remove private
          # method, which will ideally be refactored eventually
          allow(s).to receive(:available).and_return([Suite.last])
        end
      end
    end

    def mock_params(suite_ids_1: nil, drawn_ids_1: nil,
                    drawless_ids_1: nil, **overrides)
      # takes the default size from the factory :draw_with_members /
      # :suites_with_rooms
      hash = {
        suite_ids_1: suite_ids_1, drawn_ids_1: drawn_ids_1,
        drawless_ids_1: drawless_ids_1
      }.merge(overrides)
      instance_spy('ActionController::Parameters', to_h: hash)
    end

    def create_drawn_suite
      draw = FactoryGirl.create(:draw_with_members, suites_count: 1)
      draw.suites.first
    end
  end
end
