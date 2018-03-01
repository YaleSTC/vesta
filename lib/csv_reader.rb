# frozen_string_literal: true

# Utility class to read in CSV files, handle invalid characters, and clean up
# the data.
class CSVReader
  include Callable

  # Initialize the CSVReader
  #
  # @param filename [String] the filename of the CSV file
  def initialize(filename:)
    @filename = filename
  end

  # Read in the CSV file, clean invalid UTF-8 characters, remove whitespace from
  # the header row, and clean line endings
  #
  # @return [Array<String>] an array of the rows of the CSV file
  def read
    string = File.read(filename)
                 .encode('UTF-8', 'binary',
                         invalid: :replace, undef: :replace, replace: '')
    lines = split_and_clean_line_endings(string)
    lines = process_header_line(lines)
    remove_empty_rows_and_columns(lines)
  end

  make_callable :read

  private

  attr_reader :filename

  def split_and_clean_line_endings(string)
    string.split(/(\r?\n)|\r/)
          .reject { |s| /(\r?\n)|\r/.match(s) }
  end

  def process_header_line(lines)
    lines.tap do |ls|
      ls.first.gsub!(/\s+/, '')
      ls.first.downcase!
    end
  end

  def remove_empty_rows_and_columns(lines)
    # #split will automatically remove empty columns at the end of ALL rows and
    # turn any empty row into [], so we can easily remove empty rows
    array = lines.map { |l| l.split(',') }.reject(&:empty?)
    width = array.first.length

    # Add back any needed columns to keep all rows the same length and re-join
    # each row with commas
    array.map do |l|
      (width - l.length).times { l << '' }
      l.join(',')
    end
  end
end
