# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UngroupedStudentsQuery do
  it 'returns all students without a membership' do
    ungrouped = FactoryGirl.create(:student)
    _grouped = create_student_with_group
    result = described_class.call
    expect(result).to eq([ungrouped])
  end

  it 'returns only reps and students' do
    students = %i(student rep).map { |r| FactoryGirl.create(:user, role: r) }
    _admin = FactoryGirl.create(:admin)
    result = described_class.call
    expect(result.sort_by(&:id)).to eq(students)
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
    student1, student2 = FactoryGirl.create_pair(:student)
    result = described_class.new(User.where.not(id: student1.id)).call
    expect(result).to eq([student2])
  end

  it 'orders by last name' do
    student1, student2 = FactoryGirl.create_pair(:student)
    student1.update!(last_name: 'B')
    student2.update!(last_name: 'A')
    expect(described_class.call).to eq([student2, student1])
  end

  def create_student_with_group
    draw = FactoryGirl.create(:draw)
    suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    draw.suites << suite
    FactoryGirl.create(:student, draw: draw).tap do |s|
      FactoryGirl.create(:group, draw: draw, size: suite.size, leader: s)
    end
  end

  def create_invited_student
    create_student_with_unaccepted_membership('invited')
  end

  def create_requested_student
    create_student_with_unaccepted_membership('requested')
  end

  def create_student_with_unaccepted_membership(status)
    group = FactoryGirl.create(:drawless_group, size: 2)
    FactoryGirl.create(:student).tap do |s|
      Membership.create!(user_id: s.id, group_id: group.id, status: status)
    end
  end
end
