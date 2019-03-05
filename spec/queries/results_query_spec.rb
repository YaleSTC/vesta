# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsQuery do
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

  it 'includes room assignment if one exists' do
    stdt = create_roomed_student
    expect(described_class.call.first.room).to eq(stdt.room)
  end

  it 'includes building name even without room' do
    stdt = create(:student_in_draw)
    create(:group_with_suite, leader: stdt)
    expect(described_class.call.first.building_name).not_to eq(nil)
  end

  it 'includes other arbitrary information, i.e. lottery number' do
    stdt = create(:student_in_draw)
    create(:group_with_suite, leader: stdt)
    expect(described_class.call.first.lottery_number).to eq(stdt.lottery_number)
  end

  it 'only includes active students' do
    stdt = create(:student_in_draw, role: 'graduated')
    expect(described_class.call).not_to include stdt
  end

  def create_roomed_student(**params)
    group = create(:group, leader: create(:student_in_draw, params))
    create(:room_assignment, user: group.leader)
    group.leader
  end
end
