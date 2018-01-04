# frozen_string_literal: true

# Seed script generator for suite selection draws
class SuiteSelectionDrawGenerator < LotteryDrawGenerator
  private

  def update_status
    assign_lottery_numbers
    super
  end

  def assign_lottery_numbers
    draw.update(status: 'lottery')
    draw.groups.each do |g|
      LotteryAssignment.create(groups: [g], draw: draw, number: g.id)
    end
  end

  def status
    'suite_selection'
  end
end
