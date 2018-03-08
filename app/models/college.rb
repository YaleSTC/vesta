# frozen_string_literal: true

# Model for site configuration / individual colleges. Will be used for
# multi-tenancy in the future.
#
# @attr name [String] the college name
# @attr admin_email [String] the admin e-mail for the college
# @attr dean [String] the name of the college dean / head
# @attr site_url [String] the full url (including http/https) for the Vesta site
#   for the college
# @attr floor_plan_url [String] the url to access floor plans
# @attr student_info_text [Text] a paragraph of text viewable on the student
#   dashboard
class College < ApplicationRecord
  validates :name, presence: true
  validates :admin_email, presence: true
  validates :dean, presence: true
  validates :subdomain, uniqueness: { case_sensitive: false }

  before_validation :set_subdomain
  before_update :freeze_subdomain
  after_create :create_schema!
  after_destroy :drop_schema!

  # Returns the current Apartment tenant. Raises an ActiveRecord::RecordNotFound
  # exception if the tenant does not exist (shouldn't be possible unless we're
  # in the public schema).
  #
  # @return [College] the current college or a null college
  def self.current
    find_by!(subdomain: Apartment::Tenant.current)
  end

  # Activate a given college, by subdomain
  #
  # @param subdomain [String] the subdomain of the college to activate
  def self.activate!(subdomain)
    find_by(subdomain: subdomain).activate!
  end

  # Switch to the college's Postgres schema
  def activate!
    Apartment::Tenant.switch!(subdomain)
  end

  # Return the college host - prepends the subdomain to the ENV-configured
  # canonical host.
  #
  # @return [String] the host for a given college's subdomain
  def host
    "#{subdomain}.#{env('APPLICATION_HOST')}"
  end

  private

  def set_subdomain
    return if subdomain.present?
    assign_attributes(subdomain: URI.encode_www_form_component(name&.downcase))
  end

  def freeze_subdomain
    return unless will_save_change_to_subdomain?
    throw(:abort)
  end

  def create_schema!
    Apartment::Tenant.create(subdomain)
  end

  def drop_schema!
    Apartment::Tenant.drop(subdomain)
  end
end
