# frozen_string_literal: true

# Seed script generator for lottery draws
class LotteryDrawGenerator < DrawGenerator
  private

  def add_members
    super
    lock_groups
  end

  def lock_groups
    draw.groups.each do |g|
      GroupLocker.lock(group: g)
    end
  end

  def update_status
    super
    DrawLotteryStarter.start(draw: draw)
  end

  def status
    'lottery'
  end
end
