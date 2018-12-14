# frozen_string_literal: true

# Service object to handle cleaning up vesta for next year's draws.
class CollegeArchiver
  include ActiveModel::Model
  include Callable

  # Archive a Draw
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the created object.
  def archive
    ActiveRecord::Base.transaction do
      archive_draws
      archive_drawless_groups
      archive_users
      raise ActiveRecord::ActiveRecordError if errors.present?
    end
    success
  rescue ActiveRecord::ActiveRecordError
    error
  end

  make_callable :archive

  private

  def archive_draws
    Draw.where(active: true).each do |d|
      error = DrawArchiver.archive(draw: d).dig(:msg, :error)
      errors.add(:base, error) if error.present?
    end
  end

  def archive_drawless_groups
    error = DrawlessGroupArchiver.archive.dig(:msg, :error)
    errors.add(:base, error) if error.present?
  end

  def archive_users
    users = User.where(college: College.current, role: %w(student rep))
    users.map { |u| u.update!(role: 'graduated') }
  end

  def success
    { redirect_object: nil, msg: { success: 'Past housing data archived.' } }
  end

  # We will be redirecting to the college#edit path for both success and error
  def error
    msg = ErrorHandler.format(error_object: self)
    { redirect_object: nil,
      msg: { error: "There was a problem archiving the college:\n#{msg}" } }
  end
end
