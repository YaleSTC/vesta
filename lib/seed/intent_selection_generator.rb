# frozen_string_literal: true

# Seed script generator for intent-selection draws
class IntentSelectionGenerator < DrawGenerator
  private

  def status
    'intent_selection'
  end

  def add_members
    members = Generator.generate(model: 'user', count: 20)
    members.map do |m|
      DrawMembership.create!(user: m, draw: draw, active: true,
                             intent: DrawMembership.intents.keys.sample)
    end
  end
end
