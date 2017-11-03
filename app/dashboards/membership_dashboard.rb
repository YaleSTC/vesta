# frozen_string_literal: true

require 'administrate/base_dashboard'

# administrate dashboard for memberships
class MembershipDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    group: Field::BelongsTo,
    user: Field::BelongsTo,
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String.with_options(searchable: false),
    locked: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    user
    group
    status
    locked
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    group
    user
    id
    created_at
    updated_at
    status
    locked
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    user
    group
    status
    locked
  ).freeze

  # Overwrite this method to customize how memberships are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(membership)
    "#{membership.user.full_name} for #{membership.group.name}"
  end
end
