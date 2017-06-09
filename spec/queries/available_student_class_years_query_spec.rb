# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailableStudentClassYearsQuery do
  describe '#call' do
    it 'finds all the class years of available students' do
      FactoryGirl.create(:student, class_year: 2016)
      FactoryGirl.create(:student_in_draw, class_year: 2017)
      FactoryGirl.create(:drawless_group).leader.update(class_year: 2018)
      expect(described_class.call).to eq([2016])
    end
    it 'ignores duplicates' do
      FactoryGirl.create_pair(:student, class_year: 2016)
      expect(described_class.call).to eq([2016])
    end
    it 'takes a relation in the constructor to limit the query' do
      FactoryGirl.create(:student, class_year: 2016)
      FactoryGirl.create(:student, class_year: 2017)
      query_object = described_class.new(User.where(class_year: 2016))
      expect(query_object.call).to eq([2016])
    end
    it 'sorts the results' do
      FactoryGirl.create(:student, class_year: 2017)
      FactoryGirl.create(:student, class_year: 2016)
      expect(described_class.call).to eq([2016, 2017])
    end
  end
end
