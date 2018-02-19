# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CSVGenerator do
  let(:data) { create_data }
  let(:a) { %i(username intent) }

  context 'successfully' do
    it 'creates a csv' do
      result = described_class.generate(data: data, attributes: a, name: 'test')
      export = "username,intent\n" + data.map { |n| export_row_for(n) }.join
      expect(result[:file]).to eq(export)
    end

    it 'creates the filename' do
      result = described_class.generate(data: data, attributes: a, name: 'test')
      time_str = Time.zone.today.to_s(:number)
      file_name = "vesta_test_export_#{time_str}.csv"
      expect(result[:filename]).to eq(file_name)
    end

    it 'adds a csv type to the hash' do
      result = described_class.generate(data: data, attributes: a, name: 'test')
      expect(result[:type]).to eq('text/csv')
    end
  end

  context 'unsuccessfully' do
    it 'raises an error if there is no data passed' do
      result = described_class.generate(data: [], attributes: a, name: 'test')
      expect(result).to have_key(:errors)
    end

    it 'raises an error if the data does not respond to the attribues passed' do
      bad = %i(bad attributes)
      r = described_class.generate(data: data, attributes: bad, name: 'test')
      error_str = 'Data does not respond to the attribute'
      expect(r[:errors]).to include(error_str)
    end

    it 'raises an error if the attributes are not strings or symbols' do
      bad = [1, 2, 3]
      r = described_class.generate(data: data, attributes: bad, name: 'test')
      error_str = 'Attributes must be strings or symbols.'
      expect(r[:errors]).to include(error_str)
    end
  end

  def export_row_for(student)
    [student.username, student.intent].join(',') + "\n"
  end

  def create_data
    draw = create(:draw_with_members, students_count: 4)
    draw.students.last.update(intent: 'off_campus')
    draw.students.first.update(intent: 'undeclared')
    draw.students
  end
end
