# frozen_string_literal: true

require 'csv'
require 'csv_reader'

# Form Object for Intents Importing
class IntentsImportForm
  include ActiveModel::Model
  include Callable

  # Initialize a new IntentsImportForm
  #
  # @param file [String] The path to the CSV
  # @param students [User::ActiveRecord_Relation] the students in the draw
  def initialize(file: nil, students:)
    @file = file
    @students = students
    @successes = []
    @failures = []
    @login_attr = User.login_attr
  end

  # Import a set of intents from a CSV file. The file should have the header
  # "username,intent" or "email,intent" where the first column is the
  # identifying attribute for the user and Intent is either on_campus or
  # off_campus.
  #
  # @return [Hash{Symbol=>nil,Hash}] A hash with flash messages to be set.
  def import
    return error('No file uploaded') unless file
    @body = CSVReader.read(filename: file)
    return error('Header incorrect') unless correct_header?
    CSV.parse(body.join("\n"), headers: true).each do |row|
      update_intent_from_row(row: row.to_hash.symbolize_keys)
    end
    result
  end

  make_callable :import

  private

  attr_accessor :successes, :failures
  attr_reader :body, :students, :file, :login_attr

  def update_intent_from_row(row:)
    student = find_student(row)
    student.update!(intent: row[:intent])
    successes << row[login_attr]
  rescue
    failures << row[login_attr]
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
    "Successfully updated #{successes.size} intents."
  end

  def failure_msg
    return nil if failures.empty?
    "Failed to update intents from the following rows: #{failures.join(', ')}."
  end

  def error(msg)
    { redirect_object: nil, msg: { error: msg } }
  end

  def correct_header?
    body.first.split(',') == %W[#{User.login_attr} intent]
  end

  def find_student(row)
    students.find_by!(login_attr => row[login_attr])
  end
end
