# frozen_string_literal: true

require 'administrate/field/base'

# Custom Administrate field for array attributes
class ArrayField < Administrate::Field::Base
  def to_s
    if data.empty?
      'None'
    else
      data.compact.join(', ')
    end
  end

  def permitted_values
    options[:permitted_values]
  end

  def current_values
    data
  end
end
