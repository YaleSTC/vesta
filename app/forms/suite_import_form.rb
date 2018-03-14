# frozen_string_literal: true

require 'csv'
require 'csv_reader'

# Form Object for Suite Importing
class SuiteImportForm
  include ActiveModel::Model
  include Callable

  HEADER = %w(number common single double medical).freeze

  # Initialize a new SuiteImporter
  #
  # @param [String] file The path to the CSV
  # @param [Building] building The building to put the suites in
  def initialize(file: nil, building:)
    @building = building
    @file = file
    @successes = []
    @failures = []
  end

  # Import a set of suites from a CSV file. The file should have the header
  # "number,common,single,double,medical" where Number is the suite number and
  # Common, Single, and Double contain the room numbers for the rooms of that
  # size, separated by spaces. Medical suites are indicated by having any
  # content in the Medical column.
  #
  # @return [Hash{Symbol=>nil,Hash}] A hash with flash messages to be set.
  def import
    return error('No file uploaded') unless file
    @body = CSVReader.read(filename: file)
    return error('Header incorrect') unless correct_header?
    CSV.parse(@body.join("\n"), headers: true).each do |row|
      create_suite_from_row(row: row.to_hash.symbolize_keys)
    end
    result
  end

  make_callable :import

  private

  attr_accessor :successes, :failures
  attr_reader :body, :building, :file

  BED_COUNTS = { common: 0, single: 1, double: 2 }.freeze

  def create_suite_from_row(row:)
    ActiveRecord::Base.transaction do
      suite = Suite.create!(number: row[:number], building: building,
                            medical: row[:medical].present?)
      create_rooms(suite: suite, row: row.except!(:number, :medical))
    end
    successes << row[:number]
  rescue ActiveRecord::RecordInvalid
    failures << row[:number]
  end

  def create_rooms(suite:, row:)
    row.each do |type, room_numbers|
      next unless room_numbers.present?
      room_numbers.split(/\s+/).each do |number|
        Room.create!(beds: BED_COUNTS[type], suite: suite, number: number)
      end
    end
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
end
