# frozen_string_literal: true

require 'administrate/base_dashboard'

# Administrate dashboard for DrawMemberships
class DrawMembershipDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    draw: Field::BelongsTo,
    led_group: Field::HasOne.with_options(class_name: 'Group'),
    membership: Field::HasOne,
    group: Field::HasOne,
    memberships: Field::HasMany,
    room_assignment: Field::HasOne,
    room: Field::HasOne,
    id: Field::Number,
    old_draw: Field::BelongsTo.with_options(class_name: 'Draw'),
    intent: EnumField,
    active: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    user
    draw
    intent
    membership
    active
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    user
    draw
    membership
    group
    memberships
    room
    id
    old_draw
    intent
    active
    created_at
    updated_at
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    user
    old_draw
    draw
    intent
  ).freeze

  # Overwrite this method to customize how draw memberships are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(draw_membership)
  #   "DrawMembership ##{draw_membership.id}"
  # end
end
