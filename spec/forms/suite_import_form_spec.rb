# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteImportForm do
  include ActionDispatch::TestProcess
  describe '.import' do
    xit 'calls #import on a new instance'
  end

  context 'valid csv' do
    let(:building) { instance_spy('Building') }
    let(:file) { fixture_file_upload(csv_path('suite_upload'), 'text/csv') }

    before { stub_suite_create }

    it 'creates the suites' do
      described_class.import(file: file, building: building)
      expect(Suite).to have_received(:create!).twice
    end
    it 'returns nil in :redirect_object' do
      result = described_class.import(file: file, building: building)
      expect(result[:redirect_object]).to be_nil
    end
    it 'returns a success flash' do
      result = described_class.import(file: file, building: building)
      expect(result[:msg].keys).to eq([:success])
    end
    it 'creates the rooms' do
      # from the fixture
      count = 6
      described_class.import(file: file, building: building)
      expect(Room).to have_received(:create!).exactly(count)
    end

    def stub_suite_create
      allow(Suite).to receive(:create!)
        .and_return(instance_spy('Suite', number: 'L01'))
      allow(Room).to receive(:create!)
    end
  end

  context 'missing header' do
    let(:building) { instance_spy('Building') }
    let(:file) { fixture_file_upload(csv_path('suite_no_header'), 'text/csv') }

    before { allow(Suite).to receive(:create!) }

    it 'creates no suites' do
      described_class.import(file: file, building: building)
      expect(Suite).not_to have_received(:create!)
    end
    it 'returns nil in :redirect_object' do
      result = described_class.import(file: file, building: building)
      expect(result[:redirect_object]).to be_nil
    end
    it 'returns an error flash' do
      result = described_class.import(file: file, building: building)
      expect(result[:msg].keys).to eq([:error])
    end
  end

  context 'some create failures' do
    let(:building) { instance_spy('Building') }
    let(:file) { fixture_file_upload(csv_path('suite_upload'), 'text/csv') }

    before { stub_suite_create(building) }

    it 'returns building in :redirect_object' do
      result = described_class.import(file: file, building: building)
      expect(result[:redirect_object]).to be_nil
    end
    it 'returns an error flash and a success flash' do
      result = described_class.import(file: file, building: building)
      expect(result[:msg].keys).to match_array(%i(success error))
    end
    def stub_suite_create(building)
      allow(Suite).to receive(:create!)
        .and_return(instance_spy('Suite', number: 'L01'))
      allow(Suite).to receive(:create!).with(building: building, number: 'H42')
        .and_raise('ERROR')
      allow(Room).to receive(:create!)
    end
  end

  def csv_path(filename)
    Rails.root.join('spec', 'fixtures', "#{filename}.csv")
  end
end
