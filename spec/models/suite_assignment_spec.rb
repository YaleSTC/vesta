# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteAssignment do
  describe '#remove' do
    it 'delegates to an instance of SuiteRemover' do
      gs = [instance_spy('group', id: 1)]
      s_r = instance_spy('SuiteRemover', remove: true)
      allow(SuiteRemover).to receive(:new).with(group: gs.first).and_return(s_r)
      described_class.new(groups: gs).remove
      expect(s_r).to have_received(:remove)
    end
  end

  describe '#prepare' do
    it 'sets the relevant instance variables' do
      gs = [instance_spy('group', id: 1)]
      ps = { 'suite_id_for_1' => '1' }
      result = described_class.new(groups: gs).prepare(params: ps)
      expect(result.instance_variable_get('@suite_id_for_1')).to eq('1')
    end
    it 'ignores irrelevant params' do
      gs = [instance_spy('group', id: 1)]
      ps = { 'suite_id_for_1' => '1', 'suite_id_for_2' => '2' }
      result = described_class.new(groups: gs).prepare(params: ps)
      expect(result.instance_variable_get('@suite_id_for_2')).to be_nil
    end
    it 'ignores empty params' do
      gs = Array.new(2) { |i| instance_spy('group', id: i + 1) }
      ps = { 'suite_id_for_1' => '1', 'suite_id_for_2' => '' }
      result = described_class.new(groups: gs).prepare(params: ps)
      expect(result.instance_variable_get('@suite_id_for_2')).to be_nil
    end
  end

  describe '#assign' do
    context 'success' do
      let(:groups) do
        Array.new(2) { |i| instance_spy('group', id: i + 1, draw: nil) }
      end
      let(:params) { mock_params(1 => 1, 2 => 2) }
      let!(:selectors) { mock_valid_selectors }
      let(:bulk_selector) do
        described_class.new(groups: groups).prepare(params: params)
      end

      it 'returns a null object' do
        result = bulk_selector.assign
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns a null service object' do
        result = bulk_selector.assign
        expect(result[:service_object]).to be_nil
      end
      it 'returns a success message' do
        result = bulk_selector.assign
        expect(result[:msg].keys).to eq([:success])
      end
      it 'calls select on all suite selectors generated' do
        bulk_selector.assign
        expect(selectors).to all(have_received(:select))
      end
    end

    describe 'validations' do
      let(:groups) do
        Array.new(2) do |i|
          instance_spy('group', id: i + 1, draw: nil, name: "Foo#{i + 1}")
        end
      end

      it 'all groups to have been passed' do
        ps = mock_params(1 => 1)
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:msg][:error]).to include('select a suite for all groups')
      end
      it 'duplicate suites' do
        ps = mock_params(1 => 1, 2 => 1)
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:msg][:error]).to include('select different suites')
      end
      it 'returns errors from all SuiteSelectors' do
        ps = mock_params(1 => 1, 2 => 2)
        mock_failing_selectors
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:msg][:error]).to include('Foo1 - 1, Foo2 - 2')
      end
      it 'a draw mismatch' do
        groups = prepare_draw_mismatch_data
        ps = mock_params(1 => 1)
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:msg][:error]).to include('to suites in the same draw')
      end
    end

    context 'failure' do
      let(:groups) do
        Array.new(2) do |i|
          instance_spy('group', id: i + 1, draw: nil, name: "Foo#{i + 1}")
        end
      end

      it 'sets a nil object' do
        ps = mock_params(1 => 1)
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets the service object' do
        ps = mock_params(1 => 1)
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:service_object]).to eq(bulk_selector)
      end
      it 'sets an error message' do
        ps = mock_params(1 => 1)
        bulk_selector = described_class.new(groups: groups).prepare(params: ps)
        result = bulk_selector.assign
        expect(result[:msg].keys).to eq([:error])
      end
    end

    def prepare_draw_mismatch_data # rubocop:disable MethodLength, AbcSize
      draw = instance_spy('draw')
      instance_spy('Suite::ActiveRecord_Association').tap do |s|
        allow(s).to receive(:include?).and_return(false)
        allow(s).to receive(:available).and_return(s)
        allow(draw).to receive(:suites).and_return(s)
      end
      groups = [instance_spy('group', id: 1, draw: draw)]
      instance_spy('suite').tap do |s|
        allow(Suite).to receive(:find_by).with(id: '1').and_return(s)
        allow(Suite).to receive(:find_by).with(id: 1).and_return(s)
      end
      groups
    end

    def mock_valid_selectors
      groups.map do |g|
        instance_spy('suite_selector').tap do |s|
          allow(s).to receive(:errors).and_return([])
          allow(SuiteSelector).to receive(:new)
            .with(group: g, suite_id: g.id.to_s).and_return(s)
        end
      end
    end

    def mock_failing_selectors # rubocop:disable AbcSize
      groups.map do |g|
        instance_spy('suite_selector').tap do |s|
          allow(s).to receive(:errors).and_return([g.id.to_s])
          allow(SuiteSelector).to receive(:new)
            .with(group: g, suite_id: g.id.to_s).and_return(s)
        end
      end
    end

    def mock_params(params_hash)
      params_hash.each_with_object({}) do |(k, v), out|
        out["suite_id_for_#{k}"] = v.to_s
      end
    end
  end

  describe '#valid_field_ids' do
    it 'returns a list of valid form field ids as symbols' do
      groups = Array.new(2) { |i| instance_spy('group', id: (i + 1)**2) }
      s = described_class.new(groups: groups)
      expect(s.valid_field_ids).to eq(%i(suite_id_for_1 suite_id_for_4))
    end
  end
end
