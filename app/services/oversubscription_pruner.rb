# frozen_string_literal: true

require 'securerandom'

# Service object to handle oversubscribed groups of a given suite size, by
# randomly disbanding suites in excess of those currently available. Validates
# that the size given is indeed oversubscribed and is in the draw. Locks
# sizes after resolving oversubscription
class OversubscriptionPruner
  include ActiveModel::Model
  include ApplicationHelper
  include Callable

  validate :all_sizes_in_draw
  validate :all_sizes_oversubscribed

  # Initialize a new OversubscriptionPruner
  #
  # @param draw_report [DrawReport] the draw in question, wrapped by DrawReport
  # @param sizes [Array<Integer>] the sizes to prune, as integers
  #
  # @return [Hash{Symbol=>DrawReport,Hash,nil}] A results hash with the
  #   messages to set in the flash and `nil`.
  def initialize(draw_report:, sizes:)
    @draw_report = draw_report
    @sizes = sizes
    @oversubscribed = draw_report.oversubscribed_sizes
    @disbanded = {}
  end

  def prune
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      sizes.each { |size| destroy_groups! size }
      lock_sizes!
    end
    success
  rescue ActiveRecord::RecordNotDestroyed => e
    return error(e)
  rescue ActiveRecord::RecordInvalid => e
    return error(e)
  end

  make_callable :prune

  private

  attr_reader :draw_report, :sizes, :oversubscribed, :disbanded

  def all_sizes_in_draw
    missing_sizes = sizes - draw_report.sizes
    return if missing_sizes.empty?
    missing_sizes.each do |size|
      errors.add(:base, "#{headerize_size(size)} must be in the draw")
    end
  end

  def all_sizes_oversubscribed
    not_oversubscribed = sizes - oversubscribed
    return if not_oversubscribed.empty?
    not_oversubscribed.each do |size|
      errors.add(:base, "#{headerize_size(size)} must be oversubscribed")
    end
  end

  def destroy_groups!(size)
    # takes place within a transaction
    shuffle = draw_report.groups.where(size: size).shuffle(random: SecureRandom)
    unlucky = shuffle.pop(-draw_report.oversubscription[size])
    unlucky.map(&:destroy!)
    disbanded[size] = unlucky.map(&:name)
  end

  def lock_sizes!
    # takes place within a transaction
    sizes = disbanded.keys.reject { |s| draw_report.size_locked? s }
    draw_report.locked_sizes.push(*sizes)
    draw_report.save!
  end

  def success
    obj = draw_report.refresh.oversubscribed? ? nil : draw_report
    msg = disbanded.to_a.map do |size, names|
      "#{headerize_size(size)} disbanded: #{names.join(', ')}."
    end
    { redirect_object: obj, msg: { success: msg.join('\n') } }
  end

  def error(error_obj)
    msg = 'Oversubscription pruning failed: '\
      "#{ErrorHandler.format(error_object: error_obj)}."
    { redirect_object: nil, msg: { error: msg } }
  end
end
