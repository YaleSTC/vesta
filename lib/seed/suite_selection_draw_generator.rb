# frozen_string_literal: true

# Seed script generator for suite selection draws
class SuiteSelectionDrawGenerator < LotteryDrawGenerator
  private

  def update_status
    super
    assign_lottery_numbers
  end

  def assign_lottery_numbers
    draw.groups.each do |g|
      g.lottery_number = (g.id / 2).round
    end
  end

  def status
    'suite_selection'
  end
end
