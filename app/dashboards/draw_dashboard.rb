# frozen_string_literal: true

require 'administrate/base_dashboard'

# administrate dashboard for draws
class DrawDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    groups: Field::HasMany,
    students: Field::HasMany.with_options(class_name: 'User'),
    draw_suites: Field::HasMany,
    suites: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String.with_options(searchable: false),
    intent_deadline: Field::DateTime,
    locked_sizes: ArrayField.with_options(permitted_values: (1..12).to_a),
    intent_locked: Field::Boolean,
    last_email_sent: Field::DateTime,
    email_type: Field::String.with_options(searchable: false),
    locking_deadline: Field::DateTime,
    suite_selection_mode: Field::String.with_options(searchable: false)
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i(
    name
    status
    groups
    students
    suites
  ).freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i(
    id
    name
    status
    locking_deadline
    locked_sizes
    intent_deadline
    intent_locked
    last_email_sent
    email_type
    suite_selection_mode
    created_at
    updated_at
    groups
    students
    suites
  ).freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i(
    name
    status
    intent_deadline
    locked_sizes
    intent_locked
    last_email_sent
    email_type
    locking_deadline
    suite_selection_mode
    groups
    students
    suites
  ).freeze

  # Overwrite this method to customize how draws are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(draw)
    draw.name
  end
end
