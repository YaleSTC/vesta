# frozen_string_literal: true

# Seed script data factory
module Generator
  require 'ffaker'
  # require 'ruby-progressbar'

  # PROGRESS_STR = '%t: [%B] %P%% | %c / %C | %E'

  GENERATORS = { user: UserGenerator, building: BuildingGenerator,
                 suite: SuiteGenerator, room: RoomGenerator,
                 draw: DrawGenerator, college: CollegeGenerator }.freeze

  def self.generate(model:, count: 1, **overrides)
    # puts "Generating #{count} #{model.camelize}...\n"
    # progress = ProgressBar.create(format: PROGRESS_STR, total: count)
    count.times do
      GENERATORS[model.downcase.to_sym].generate(overrides: overrides)
      # progress.increment
    end
  end

  def self.generate_admin(**overrides)
    GENERATORS[:user].generate_admin(**overrides)
  end
end
