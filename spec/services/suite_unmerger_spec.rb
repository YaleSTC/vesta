# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteUnmerger do
  context 'suite that was not previously merged' do
    let(:suite) { FactoryGirl.create(:suite, size: 2) }

    it 'returns an error flash' do
      result = described_class.unmerge(suite: suite)
      expect(result[:msg].keys).to match_array([:error])
    end
    it 'redirects to the suite' do
      result = described_class.unmerge(suite: suite)
      expect(result[:redirect_object]).to eq([suite.building, suite])
    end
  end
  context 'merged suite' do
    let(:numbers) { %w(L01 I33) }
    let(:l_room) { FactoryGirl.create(:room, original_suite: 'L01') }
    let(:i_room) { FactoryGirl.create(:room, original_suite: 'I33') }
    let!(:suite) { FactoryGirl.create(:suite, rooms: [l_room, i_room]) }
    let(:building) { suite.building }

    context 'success' do
      it 'creates new suites' do
        expect { described_class.unmerge(suite: suite) }.to \
          change { Suite.count }.by(1)
      end
      it 'destroys the merged suite' do
        described_class.unmerge(suite: suite)
        expect { Suite.find(suite.id) }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end
      it 'properly splits rooms' do
        described_class.unmerge(suite: suite)
        expect(Suite.where(number: 'L01').first.rooms).to match_array([l_room])
      end
      it 'returns a success flash' do
        result = described_class.unmerge(suite: suite)
        expect(result[:msg].keys).to match_array([:success])
      end
      it 'returns the building in :redirect_object' do
        result = described_class.unmerge(suite: suite)
        expect(result[:redirect_object]).to eq(building)
      end
    end
    context 'failure' do
      it 'returns an error flash' do
        FactoryGirl.create(:suite, number: numbers.first,
                                   building: suite.building)
        result = described_class.unmerge(suite: suite)
        expect(result[:msg].keys).to match_array([:error])
      end
      it 'redirects to the suite' do
        FactoryGirl.create(:suite, number: numbers.first,
                                   building: suite.building)
        result = described_class.unmerge(suite: suite)
        expect(result[:redirect_object]).to eq([suite.building, suite])
      end
    end
  end
end
