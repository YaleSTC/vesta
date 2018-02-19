# frozen_string_literal: true

require 'csv'

# Service object to create csvs for export.
# Will parse the passed relation for information and add it to a csv which
# it will return.
class CSVGenerator
  include Callable
  include ActiveModel::Model

  validates :data,
            presence: { message: 'must exist before it can be exported.' }

  # Initialize a new CSVGenerator
  #
  # @param data [ActiveRecord:Relation] The data to export.
  # @param name [String] The name of the attributes being exported.
  # @param attributes [Array<Symbol,String>] The attributes of each
  #   record to export.
  def initialize(data:, attributes:, name:)
    @data = data
    @attributes = attributes
    @name = name
  end

  # Generate a CSV
  #
  # @return [Hash{Symbol=>String}] A hash containing the csv and relevant export
  #   export information
  def generate
    return error unless valid?
    generate_csv_file
    success
  rescue TypeError
    errors.add(:base, 'Attributes must be strings or symbols.')
    error
  rescue NoMethodError => e
    errors.add(:base, "Data does not respond to the attribute #{e.name}.")
    error
  end

  make_callable :generate

  private

  attr_reader :data, :attributes

  def success
    { file: @file, filename: csv_filename(@name), type: 'text/csv' }
  end

  def error
    error_msgs = ErrorHandler.format(error_object: self)
    {
      file: nil, filename: nil, type: nil,
      errors: "Please review the errors below:\n#{error_msgs}"
    }
  end

  def generate_csv_file
    @file = CSV.generate do |csv|
      csv << attributes.map(&:to_s)
      data.each do |object|
        csv << attributes.map { |a| object.send(a) }
      end
    end
  end

  def csv_filename(name)
    time_str = Time.zone.today.to_s(:number)
    "vesta_#{name}_export_#{time_str}.csv"
  end
end
