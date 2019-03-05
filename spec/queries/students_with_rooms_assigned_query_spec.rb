# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentsWithRoomsAssignedQuery do
  it 'returns only students with rooms' do
    assigned = create_roomed_student
    _unassigned = create(:student_in_draw)
    expect(described_class.call).to match_array([assigned])
  end

  it 'returns only reps and students' do
    expected = [create_roomed_student,
                create_roomed_student(role: 'rep')]
    _unexpected = create_roomed_student(role: 'admin')
    expect(described_class.call).to match_array(expected)
  end

  it 'orders results by last name' do
    third = create_roomed_student(last_name: 'Clastname')
    first = create_roomed_student(last_name: 'Alastname')
    second = create_roomed_student(last_name: 'Blastname')
    expect(described_class.call).to match_array([first, second, third])
  end

  def create_roomed_student(**params)
    group = create(:group, leader: create(:student_in_draw, params))
    create(:room_assignment, user: group.leader)
    group.leader
  end
end
