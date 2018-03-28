# frozen_string_literal: true

require 'administrate/base_dashboard'

# administrate dashboard for users
class UserDashboard < Administrate::BaseDashboard
  include ActionView::Helpers::UrlHelper
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    draw: Field::BelongsTo,
    membership: Field::HasOne,
    group: Field::HasOne,
    memberships: Field::HasMany,
    room: Field::BelongsTo,
    id: Field::Number,
    email: Field::String,
    password: Field::String.with_options(searchable: false),
    role: Field::String.with_options(searchable: false),
    first_name: Field::String,
    last_name: Field::String,
    intent: Field::String.with_options(searchable: false),
    username: Field::String,
    class_year: Field::Number,
    old_draw_id: Field::Number,
    tos_accepted: Field::DateTime,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    first_name
    last_name
    role
    draw
    group
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    id
    email
    role
    first_name
    last_name
    intent
    username
    class_year
    draw
    old_draw_id
    group
    membership
    memberships
    room
    tos_accepted
    reset_password_sent_at
    remember_created_at
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    current_sign_in_ip
    last_sign_in_ip
    created_at
    updated_at
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    email
    role
    first_name
    last_name
    intent
    username
    class_year
    draw
    old_draw_id
    room
  ).freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    user.full_name
  end
end
