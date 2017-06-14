# frozen_string_literal: true

# Seed script generator for pre-lottery draws
class PreLotteryDrawGenerator < DrawGenerator
  private

  def status
    'pre_lottery'
  end
end
