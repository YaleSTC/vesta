# frozen_string_literal: true
#
# User model class for all user types. Optionally loads in sets of Devise
# modules for authentication. Validates presence of required profile fields
# (noted below).
#
# @attr email [String] the user's e-mail (required for database auth)
# @attr encrypted_password [String] the encrypted password for database
#   authentication (handled by Devise)
# @attr username [String] the user's CAS login (required for CAS auth)
# @attr role [Integer] an enum for the user's role, admin, [housing] rep, or
#   student (required)
# @attr first_name [String] the user's first name (required)
# @attr last_name [String] the user's last name (required)
# @attr intent [Integer] an enum for the user's housing intent, on_campus,
#   off_campus, or undeclared (required)
# @attr gender [Integer] an enum for the user's gender, male, female, or
#   undeclared (required)
# @attr class_year [Integer] the graduating class year of the student (optional)
# @attr college [String] a string describing the residential college to which
#   the user belongs (optional)
class User < ApplicationRecord
  # Determine whether or not CAS authentication is being used, must be at the
  # top of the class to be used in the Devise loading conditional below.
  #
  # @return [Boolean] true if the CAS_BASE_URL environment variable is set,
  #   false otherwise
  def self.cas_auth?
    env? 'CAS_BASE_URL'
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  if cas_auth?
    devise :cas_authenticatable, :trackable
  else
    devise :database_authenticatable, :recoverable, :rememberable, :trackable,
           :validatable
  end

  belongs_to :draw
  has_one :membership, -> { where(status: 'accepted') }, dependent: :destroy
  has_one :group, through: :membership
  has_many :memberships, dependent: :destroy

  validates :email, uniqueness: true
  validates :username, presence: true, if: :cas_auth?
  validates :username, uniqueness: { case_sensitive: false }, if: :cas_auth?
  validates :role, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :intent, presence: true
  validates :gender, presence: true

  enum role: %w(student admin rep)
  enum intent: %w(undeclared on_campus off_campus)
  enum gender: %w(non-binary female male)

  before_save :downcase_username, if: :cas_auth?

  # Returns the user's preferred name
  #
  # @return [String] Preferred name
  def name
    first_name
  end

  # Returns the user's preferred full name
  #
  # @return [String] Preferred name if set, otherwise first name, plus last name
  def full_name
    "#{name} #{last_name}"
  end

  private

  def downcase_username
    username.downcase!
  end

  def cas_auth?
    User.cas_auth?
  end
end
