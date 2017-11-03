# frozen_string_literal: true

require 'administrate/base_dashboard'

# administrate dashboard for rooms
class RoomDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    suite: Field::BelongsTo,
    users: Field::HasMany,
    id: Field::Number,
    number: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    beds: Field::Number
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    number
    suite
    users
    id
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    suite
    users
    id
    number
    created_at
    updated_at
    beds
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    suite
    users
    number
    beds
  ).freeze

  # Overwrite this method to customize how rooms are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(room)
    "Room #{room.number}"
  end
end
