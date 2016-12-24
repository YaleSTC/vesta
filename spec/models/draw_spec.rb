# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Draw, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:students) }
    it { is_expected.to have_and_belong_to_many(:suites) }
  end

  describe '#suite_sizes' do
    it 'returns an array of all the suite sizes in the draw' do
      suites = Array.new(3) { |size| instance_spy('Suite', size: size + 1) }
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:suites).and_return(suites)
      expect(draw.suite_sizes).to match_array([1, 2, 3])
    end
  end
end
