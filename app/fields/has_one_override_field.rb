# frozen_string_literal: true

require 'administrate/field/has_one'

# Temporary workaround; remove when
# https://github.com/thoughtbot/administrate/issues/951 is merged
class HasOneOverrideField < Administrate::Field::Associative
  def initialize(attribute, data, page, options = {})
    associated_class = options.fetch(:class_name,
                                     attribute.to_s.singularize.camelcase)
    resolver = Administrate::ResourceResolver.new("admin/#{associated_class}")
    @nested_form = Administrate::Page::Form.new(
      resolver.dashboard_class.new,
      data || resolver.resource_class.new
    )
    super
  end

  def permitted_attribute(attr)
    related_dashboard_attributes =
      Administrate::ResourceResolver.new("admin/#{associated_class}")
                                    .dashboard_class.new.permitted_attributes
    { "#{attr}_attributes": related_dashboard_attributes + [:id] }
  end

  attr_reader :nested_form

  private

  def associated_class
    options.fetch(:class_name, attribute.to_s.singularize.camelcase)
  end
end
