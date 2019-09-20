# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteDecorator do
  let(:suite_decorator) { described_class.new(create(:suite)) }
  let(:draw) { create(:draw) }
  let(:draw2) { create(:draw) }

  describe '#name_with_draws' do
    it 'returns the name if the suite belongs to no draws' do
      allow(suite_decorator).to receive(:draws).and_return([])
      expect(suite_decorator.name_with_draws).to eq(suite_decorator.name)
    end
    it 'returns the name if the suite only belongs to the passed draw' do
      suite_decorator.draws << draw
      expect(suite_decorator.name_with_draws(draw)).to eq(suite_decorator.name)
    end
    it 'ignores archived draws' do
      suite_decorator.draws << draw
      draw.update!(active: false)
      expect(suite_decorator.name_with_draws).to eq(suite_decorator.name)
    end
    it 'returns the name with other draw names' do
      suite_decorator.draws << draw
      expected = "#{suite_decorator.name} (#{draw.name})"
      expect(suite_decorator.name_with_draws).to eq(expected)
    end
    it 'excludes the passed draw' do
      draw = create(:draw_with_members, suites_count: 1, students_count: 0)
      draw.suites = draw.suites
      expected = "#{described_class.new(draw.suites.first).name} (#{draw.name})"
      expect(described_class.new(draw.suites.first).name_with_draws(draw2))
        .to eq(expected)
    end
  end

  describe '#number_with_medical' do
    let(:suite) { described_class.new(build_stubbed(:suite)) }

    it 'returns the number if not a medical suite' do
      allow(suite).to receive(:medical).and_return(false)
      expect(suite.number_with_medical).to eq(suite.number)
    end
    it 'indicates if the suite is a medical suite' do
      allow(suite).to receive(:medical).and_return(true)
      expected = "#{suite.number} (medical)"
      expect(suite.number_with_medical).to eq(expected)
    end
  end

  describe '#name' do
    let(:suite) { described_class.new(build_stubbed(:suite)) }
    let(:building) { suite.building }

    it 'returns the building name and suite number' do
      expected = "#{building.name} #{suite.number}"
      expect(suite.name).to eq(expected)
    end
  end

  describe '#name_with_medical' do
    let(:suite) { described_class.new(build_stubbed(:suite)) }
    let(:building) { suite.building }

    it 'returns the building name and suite number' do
      allow(suite).to receive(:medical).and_return(true)
      expected = "#{building.name} #{suite.number} (medical)"
      expect(suite.name_with_medical).to eq(expected)
    end
    it 'returns the name if not a medical suite' do
      allow(suite).to receive(:medical).and_return(false)
      expect(suite.name_with_medical).to eq(suite.name)
    end
  end
end
