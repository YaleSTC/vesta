# frozen_string_literal: true

# Form object for filtering intent reports; will likely be abstracted into a
# generalized report filter at some point.
class IntentReportFilter
  include ActiveModel::Model

  attr_accessor :intents

  validates :intents, presence: true

  # Filters a passed ActiveRecord relation by the intent attribute if the
  # intents attribute is set.
  #
  # @attr relation [ActiveRecord::Relation] the ActiveRecord relation to filter
  # @return [ActiveRecord::Relation] the optionally filtered relation
  def filter(relation)
    return relation unless valid?
    relation.where(intent: intents)
  end
end
