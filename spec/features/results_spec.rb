# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Results' do
  let!(:data) { create_data }
  let(:f) { "vesta_students_export_#{Time.zone.today.to_s(:number)}.csv" }
  let(:h_str) do
    'email,last_name,first_name,draw_name,intent,group_name,lottery_number,'\
    'suite_number,room_number'
  end

  before { log_in create(:admin) }

  it 'can be listed by student' do
    visit root_path
    click_on 'Results by student'
    expect(page_has_student_results(page)).to be_truthy
  end

  it 'can be listed by suite' do
    visit root_path
    click_on 'Results by suite'
    expect(page_has_room_results(page)).to be_truthy
  end

  it 'can be viewed for specific draws' do
    visit draw_path(Draw.first) # this sucks
    click_on 'View results'
    expect(page_has_room_results(page)).to be_truthy
  end

  it 'can export data by student' do
    visit students_results_path
    click_on 'Export CSV'
    expect(page_is_valid_export?(page: page, data: data[:members],
                                 filename: f, header_str: h_str)).to be_truthy
  end

  def page_has_student_results(page)
    data[:members].all? do |member|
      page.assert_selector("tr.result-student-#{member.id} td.room",
                           text: member.room.number)
    end
  end

  def page_has_room_results(page)
    data[:rooms].all? do |room|
      if !room.users.empty?
        page.assert_selector("tr.result-room-#{room.id} td.student",
                             text: room.users.first.full_name)
      else
        page.assert_selector("tr.result-room-#{room.id} td.student",
                             text: '1 transfer')
      end
    end
  end

  def export_row_for(student)
    [
      student.email, student.last_name, student.first_name, student.draw_name,
      student.intent, student.group_name, student.lottery_number,
      student.suite_number, student.room_number
    ].join(',')
  end

  def create_data # rubocop:disable MethodLength, AbcSize
    draw = create(:draw_with_members, students_count: 2,
                                      status: 'suite_selection')
    transfer = create(:open_group, leader: draw.students.last, transfers: 1)
    special = create(:drawless_group, size: 2)
    group = create(:locked_group, leader: draw.students.first)
    suite1 = create(:suite_with_rooms, rooms_count: special.size,
                                       group: special, draws: [draw])
    suite2 = create(:suite_with_rooms, rooms_count: group.size, group: group,
                                       draws: [draw])
    suite3 = create(:suite_with_rooms, rooms_count: transfer.size,
                                       group: transfer, draws: [draw])
    assign_students_to_rooms(special => suite1, group => suite2,
                             transfer => suite3)
    members = special.members.reload + group.members.reload + \
              transfer.members.reload
    rooms = suite1.rooms + suite2.rooms + suite3.rooms
    draw.update!(status: 'results')
    { members: members, rooms: rooms }
  end

  def assign_students_to_rooms(assignment_hash)
    assignment_hash.each do |group, suite|
      group.members.each_with_index do |member, i|
        member.update!(room_id: suite.rooms[i].id)
      end
    end
  end
end
