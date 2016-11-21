# frozen_string_literal: true
# User model class for all user types.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, uniqueness: true
  validates :role, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  enum role: %w(student admin rep)

  # Returns the user's preferred first name
  #
  # @return [String] Preferred name if set, otherwise first name.
  def name
    preferred_name || first_name
  end

  # Returns the user's preferred full name
  #
  # @return [String] Preferred name if set, otherwise first name, plus last name
  def full_name
    "#{name} #{last_name}"
  end

  # Returns the user's full legal name
  #
  # @return [String] The first, middle (if present), and last name of the user.
  def legal_name
    if middle_name
      "#{first_name} #{middle_name} #{last_name}"
    else
      "#{first_name} #{last_name}"
    end
  end
end
