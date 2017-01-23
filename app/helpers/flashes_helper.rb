# frozen_string_literal: true
#
# Helper module for flashes
module FlashesHelper
  def user_facing_flashes
    flash.to_hash.slice('notice', 'success', 'alert', 'error')
  end
end
