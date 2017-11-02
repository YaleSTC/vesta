# frozen_string_literal: true

# Helper methods for the Users views
module UsersHelper
  # Generate a form field for a profile attribute. Should be disabled if the
  # attribute is defined on the passed user object, and should include a hidden
  # field if disabled.
  #
  # @param form [SimpleForm::FormBuilder] the form object
  # @param user [User] the user record
  # @param field [Symbol] the field / attribute
  # @return [String] the form field, optionally disabled with a hidden field for
  #   the form to submit data
  def profile_field(form:, user:, field:)
    return form.input(field, disabled: false) if user.send(field).blank?
    form.input(field, disabled: true) + "\n" + form.input(field, as: :hidden)
  end
end
