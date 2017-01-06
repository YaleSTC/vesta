# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Draw, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:students) }
    it { is_expected.to have_and_belong_to_many(:suites) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe '#suite_sizes' do
    it 'returns an array of all the suite sizes in the draw' do
      suites = Array.new(3) { |size| instance_spy('Suite', size: size + 1) }
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:suites).and_return(suites)
      expect(draw.suite_sizes).to match_array([1, 2, 3])
    end
  end

  # this is testing a private method, feel free to remove it if it ever fails
  describe '#student_count' do
    it 'returns the number of students in the draw' do
      students = Array.new(3) { instance_spy('User') }
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:students).and_return(students)
      expect(draw.send(:student_count)).to eq(3)
    end
  end

  describe '#students?' do
    it 'returns true if the student_count is greater than zero' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:student_count).and_return(1)
      expect(draw.students?).to be_truthy
    end

    it 'returns false if the student_count is zero' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:student_count).and_return(0)
      expect(draw.students?).to be_falsey
    end
  end

  describe '#enough_beds?' do
    it 'returns true if bed_count >= student_count' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:bed_count).and_return(2)
      allow(draw).to receive(:student_count).and_return(1)
      expect(draw.enough_beds?).to be_truthy
    end

    it 'returns false if bed_count < student_count' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:bed_count).and_return(1)
      allow(draw).to receive(:student_count).and_return(2)
      expect(draw.enough_beds?).to be_falsey
    end
  end
end
