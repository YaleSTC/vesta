# frozen_string_literal: true

# Abstract base class for profile querier service objects. Determines the set of
# attributes they should return as well as the public interface they should
# expose.
class ProfileQuerier
  include Callable

  PROFILE_FIELDS =
    %i(first_name last_name email class_year).freeze

  # Initialize a ProfileQuerier
  #
  # @param id [String] the id attribute to query the web service with
  def initialize(id:)
    @id = id
  end

  # Requests user profile data from a web service
  #
  # @return [Hash{Symbol=>String},nil] either returns a hash with profile
  #   attributes that can be used to assign_attributes on a user record or nil
  #   if the lookup failed
  def query
    raise NotImplementedError
  end

  make_callable :query

  private

  attr_reader :id
end
