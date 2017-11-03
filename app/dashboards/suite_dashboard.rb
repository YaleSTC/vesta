# frozen_string_literal: true

require 'administrate/base_dashboard'

# administrate dashboard for suites
class SuiteDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    building: Field::BelongsTo,
    group: Field::BelongsTo,
    rooms: Field::HasMany,
    draw_suites: Field::HasMany,
    draws: Field::HasMany,
    id: Field::Number,
    number: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    size: Field::Number,
    medical: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    number
    size
    building
    draws
    group
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    id
    number
    size
    medical
    created_at
    updated_at
    building
    rooms
    draws
    group
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    number
    medical
    building
    rooms
    draws
    group
  ).freeze

  # Overwrite this method to customize how suites are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(suite)
    "Suite #{suite.number}"
  end
end
