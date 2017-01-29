# frozen_string_literal: true
#
# Service object for building a user record for creation. Currently takes in a
# username, ultimately will request data from IDR.
class UserBuilder
  # Allow for the calling of :build on the parent class
  def self.build(id_attr:)
    new(id_attr: id_attr).build
  end

  # Initialize a UserBuilder
  #
  # @param id_attr [String] the value for the ID attribute, either username
  # (CAS) or e-mail (non-CAS)
  def initialize(id_attr:)
    @id_attr = id_attr
    @user = User.new
    @id_symbol = User.cas_auth? ? :username : :email
  end

  # Build a user record based on the given input, ensuring that it is unique
  #
  # @return [Hash{symbol=>User,Hash}] a results hash with a message to set in
  #   the flash, nil as the :object value, the user record as the :user value,
  #   and the :action to render. The :object is always set to nil so that
  #   handle_action properly renders the template set in :action.
  def build
    return error unless unique?
    assign_login
    success
  end

  private

  attr_accessor :user
  attr_reader :id_attr, :id_symbol

  def result_hash
    { object: nil, user: user }
  end

  def success
    result_hash.merge(action: 'new',
                      msg: { success: 'Initialized user successfully' })
  end

  def error
    result_hash.merge(action: 'build',
                      msg: { error: 'User already exists' })
  end

  def unique?
    @count ||= User.where(id_symbol => id_attr).count
    @count.zero?
  end

  def assign_login
    assign_method = "#{id_symbol}=".to_sym
    user.send(assign_method, id_attr)
  end
end
