# frozen_string_literal: true

require 'ffaker'
# require 'ruby-progressbar'

# Seed script data factory
class Generator
  include Callable

  # Initializes a new generator
  # @param model [String] the model to generate
  # @param count [Integer] the number of records to generate, default is 1
  # Note: All other parameters passed serve as overrides to the specific model
  #   generator
  def initialize(model:, count: 1, **overrides)
    @model = model.downcase.to_sym
    @count = count
    @overrides = overrides
  end

  # Generate the requested number of records
  # @return [Array] an array of the generated records
  # Note that this raises an exception if the generator fails to persist a
  #   record after 50 attempts
  def generate
    # puts "Generating #{count} #{model.to_s.camelize}...\n"
    # progress = ProgressBar.create(format: PROGRESS_STR, total: count)
    Array.new(count) do
      generate_record
      # progress.increment
    end
  end

  make_callable :generate

  # Generate an admin user
  # All params are passed as overrides to the user generator
  def self.generate_superuser(**overrides)
    GENERATORS[:user].generate_superuser(**overrides)
  end

  private

  PROGRESS_STR = '%t: [%B] %P%% | %c / %C | %E'

  GENERATORS = { user: UserGenerator, building: BuildingGenerator,
                 suite: SuiteGenerator, room: RoomGenerator,
                 draw: DrawGenerator,
                 pre_lottery_draw: PreLotteryDrawGenerator,
                 lottery_draw: LotteryDrawGenerator,
                 suite_selection_draw: SuiteSelectionDrawGenerator,
                 college: CollegeGenerator }.freeze

  attr_reader :model, :count, :overrides

  def generate_record
    50.times do
      obj = GENERATORS[model].generate(overrides: overrides)
      return obj if obj&.persisted?
    end
    raise "Unable to generate the required number of #{model.to_s.pluralize}"
  end
end
