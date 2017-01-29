# frozen_string_literal: true
# User model class for all user types.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  if env? 'CAS_BASE_URL'
    devise :cas_authenticatable, :trackable
  else
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
  end

  belongs_to :draw
  has_one :membership, dependent: :destroy
  has_one :group, through: :membership

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
    env? 'CAS_BASE_URL'
  end
end
