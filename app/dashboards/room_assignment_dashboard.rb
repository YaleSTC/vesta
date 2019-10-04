# frozen_string_literal: true

require 'administrate/base_dashboard'

# Administrate dashboard for RoomAssignments
class RoomAssignmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    draw_membership: Field::BelongsTo,
    room: Field::BelongsTo,
    user: Field::HasOne,
    group: Field::HasOne,
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    id
    user
    room
    group
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    id
    user
    room
    draw_membership
    group
    created_at
    updated_at
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    draw_membership
    room
  ).freeze

  # Overwrite this method to customize how room assignments are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(room_assignment)
    "Room Assignment ##{room_assignment.id}"
  end
end
