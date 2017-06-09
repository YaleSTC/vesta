# frozen_string_literal: true

# Helper module for results
module ResultsHelper
  # Return a string describing the occupants of a room
  #
  # @param room [Room] the room in question
  # @return [String] the occupant description
  def room_occupants(room)
    students = room.users
    transfers = room.beds - students.count
    [students_str(students), transfers_str(transfers)].compact.join(', ')
  end

  private

  def students_str(students)
    students.map(&:full_name).join(', ') unless students.empty?
  end

  def transfers_str(transfers)
    pluralize(transfers, 'transfer') unless transfers.zero?
  end
end
