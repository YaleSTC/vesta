# frozen_string_literal: true

require 'administrate/field/base'

# Custon Enum Field for Administrate for enumerable attributes
class EnumField < Administrate::Field::Base
  delegate :to_s, to: :data

  def select_field_values(form_builder)
    attr = attribute.to_s.pluralize
    get_object_class(form_builder).public_send(attr)
                                  .keys.map do |v|
      [v.capitalize, v]
    end
  end

  private

  def get_object_class(input)
    input.object.class
  end
end
