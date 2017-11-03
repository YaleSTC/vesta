# frozen_string_literal: true

require 'administrate/base_dashboard'

# administrate dashboard for groups
class GroupDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    leader: Field::BelongsTo.with_options(class_name: 'User'),
    draw: Field::BelongsTo,
    suite: Field::HasOne,
    memberships: Field::HasMany,
    full_memberships: Field::HasMany.with_options(class_name: 'Membership'),
    members: Field::HasMany.with_options(class_name: 'User'),
    id: Field::Number,
    size: Field::Number,
    status: Field::String.with_options(searchable: false),
    leader_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    memberships_count: Field::Number,
    transfers: Field::Number,
    lottery_number: Field::Number
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    leader
    size
    status
    draw
    suite
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    id
    leader
    leader_id
    size
    status
    memberships_count
    transfers
    lottery_number
    draw
    suite
    memberships
    full_memberships
    created_at
    updated_at
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    leader
    size
    status
    memberships_count
    transfers
    lottery_number
    draw
    memberships
    full_memberships
  ).freeze

  # Overwrite this method to customize how groups are displayed
  # across all pages of the admin dashboard.
  def display_resource(group)
    group.name
  end
end
