# frozen_string_literal: true
#
# Model for site configuration / individual colleges. Will be used for
# multi-tenancy in the future.
#
# @attr name [String] the college name
# @attr admin_email [String] the admin e-mail for the college
# @attr dean [String] the name of the college dean / head
# @attr site_url [String] the full url (including http/https) for the Vesta site
#   for the college
class College < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :admin_email, presence: true
  validates :dean, presence: :true
  validates :site_url, presence: :true
end
