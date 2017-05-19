# frozen_string_literal: true

#
# Form Object for Suite Importing
class SuiteImportForm
  include ActiveModel::Model
  include Callable
  require 'csv'

  HEADER = %w(number singles doubles common).freeze

  # Initialize a new SuiteImporter and call #import on it
  #
  # @param [String] file The path to the CSV
  # @param [Building] building The building to put the suites in
  def initialize(file: nil, building:)
    @building = building
    @file = file
    @successes = []
    @failures = []
  end

  # Read in a CSV of suite information and create suites and rooms accordingly
  # The CSV should be formatted with a header Number, Single, Double, where
  # Single is the number of single rooms in the suite and Double is the number
  # of double rooms.
  #
  # @return [Hash{Symbol=>nil,Hash}] A hash with flash messages to be set.
  def import
    return error('No file uploaded') unless file
    prepare_csv
    return error('Header incorrect') unless correct_header?
    CSV.parse(@body.join("\n"), headers: true).each_with_index do |row, i|
      suite_from_row(row: row, index: i)
    end
    result
  end

  make_callable :import

  private

  attr_accessor :successes, :failures
  attr_reader :body, :header, :string, :building, :file

  def suite_from_row(row:, index:)
    row_number = index + 2
    ActiveRecord::Base.transaction do
      suite = Suite.create!(building: building, number: row['number'])
      create_rooms(suite: suite, row: row)
    end
    successes << row_number
  rescue
    failures << row_number
  end

  def create_rooms(suite:, row:)
    total = 0
    hash = row_counts(row)
    hash.each do |beds, count|
      count.times do |i|
        Room.create!(beds: beds, suite: suite,
                     number: room_name(suite, total + i))
      end
      total += count
    end
  end

  def row_counts(row)
    { 1 => row['singles'].to_i, 2 => row['doubles'].to_i,
      0 => row['common'].to_i }
  end

  def room_name(suite, count)
    "#{suite.number}-#{count}"
  end

  def result
    { redirect_object: nil, msg: build_flash }
  end

  def build_flash
    if successes.empty?
      { error: failure_msg }
    elsif failures.empty?
      { success: success_msg }
    else
      { success: success_msg, error: failure_msg }
    end
  end

  def success_msg
    return nil if successes.empty?
    "Successfully imported #{successes.size} suites."
  end

  def failure_msg
    return nil if failures.empty?
    "Failed to import suites from the following rows: #{failures.join(', ')}."
  end

  def error(msg)
    { redirect_object: nil, msg: { error: msg } }
  end

  def correct_header?
    return true if @body.first.split(',') == HEADER
    false
  end

  def prepare_csv
    @string = File.read(file).encode('UTF-8', 'binary',
                                     invalid: :replace, undef: :replace,
                                     replace: '')
    remove_extra_columns
    @body = clean_line_endings
    process_header_line
  end

  def process_header_line
    @body.first.gsub!(/\s+/, '')
    @body.first.downcase!
  end

  def clean_line_endings
    lines = string.split(/(\r?\n)|\r/)
    lines.reject! { |s| /(\r?\n)|\r/.match s }
    lines
  end

  def remove_extra_columns
    @string.gsub!(/,,*$/, '')
  end
end
