# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CSVReader do
  describe '#read' do
    # content comes from fixture files
    let(:expected) { ['col1,col2,col3', 'foo1,foo2,', 'bar1,bar2,bar3'] }

    it 'splits a csv into an array of lines' do
      filename = Rails.root.join('spec', 'fixtures', 'normal.csv')
      lines = described_class.read(filename: filename)
      expect(lines).to eq(expected)
    end
    it 'ignores invalid UTF-8 characters' do
      filename = Rails.root.join('spec', 'fixtures', 'invalid_utf8.csv')
      lines = described_class.read(filename: filename)
      expect(lines).to eq(expected)
    end
    it 'cleans line endings' do
      filename = Rails.root.join('spec', 'fixtures', 'crlf_endings.csv')
      lines = described_class.read(filename: filename)
      expect(lines).to eq(expected)
    end
    it 'removes whitespace and downcases the header line' do
      filename = Rails.root.join('spec', 'fixtures', 'messy_header.csv')
      lines = described_class.read(filename: filename)
      expect(lines).to eq(expected)
    end
    it 'truncates empty columns' do
      filename = Rails.root.join('spec', 'fixtures', 'extra_rows_cols.csv')
      lines = described_class.read(filename: filename)
      expect(lines).to eq(expected)
    end
  end
end
