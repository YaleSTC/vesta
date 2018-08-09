# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UngroupedStudentsQuery do
  it 'returns all students without a membership' do
    ungrouped = create(:student_in_draw)
    _grouped = create(:full_group).leader
    result = described_class.call
    expect(result).to eq([ungrouped])
  end

  it 'returns only reps and students' do
    students = %i(student rep).map { |r| create(:student_in_draw, role: r) }
    _admin = create(:admin)
    result = described_class.call
    expect(result.sort_by(&:id)).to eq(students)
  end

  it 'returns students not in draws' do
    student = create(:student)
    result = described_class.call
    expect(result).to eq([student])
  end

  it 'ignores invitations' do
    invited = create_invited_student
    expect(described_class.call).to eq([invited])
  end

  it 'ignores requests' do
    requested = create_requested_student
    expect(described_class.call).to eq([requested])
  end

  it 'restricts the results to the passed query' do
    student1, student2 = create_pair(:student_in_draw)
    result = described_class.new(User.where.not(id: student1.id)).call
    expect(result).to eq([student2])
  end

  it 'orders by last name' do
    student1, student2 = create_pair(:student_in_draw)
    student1.update!(last_name: 'B')
    student2.update!(last_name: 'A')
    expect(described_class.call).to eq([student2, student1])
  end

  def create_invited_student
    create_student_with_unaccepted_membership('invited')
  end

  def create_requested_student
    create_student_with_unaccepted_membership('requested')
  end

  def create_student_with_unaccepted_membership(status)
    group = create(:drawless_group, size: 2)
    s = create(:student)
    dm = create(:draw_membership, user: s, draw: nil, intent: 'on_campus')
    Membership.create!(draw_membership: dm, group: group, status: status)
    s
  end
end
