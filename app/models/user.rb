# frozen_string_literal: true
# User model class for all user types.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :draw
  has_one :membership
  has_one :group, through: :membership

  validates :email, uniqueness: true
  validates :role, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :intent, presence: true
  validates :gender, presence: true

  enum role: %w(student admin rep)
  enum intent: %w(undeclared on_campus off_campus)
  enum gender: %w(non-binary female male)

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
end
