# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room Selection' do
  let(:group) { FactoryGirl.create(:group_with_suite, size: 2) }

  context 'as group leader' do
    before { log_in group.leader }

    it 'can be done' do
      visit root_path
      click_on 'Assign Rooms'
      assign_rooms_to_members(group.suite.rooms, group.members)
      expect(page).to have_content('Successfully assigned rooms')
    end
  end

  context 'as admin' do
    before { log_in FactoryGirl.create(:admin) }
    context 'assignment editing' do
      before do
        group.members.each_with_index do |m, i|
          m.update(room_id: group.suite.rooms[i].id)
        end
      end

      it 'can be edited' do
        visit group_path(group)
        click_on 'Edit room assignments'
        update_room_assignments(group.suite.rooms, group.members)
        expect(page).to have_content('Successfully assigned rooms')
      end
    end

    context 'initial assignment' do
      it 'can be done' do
        visit draw_group_path(group.draw, group)
        click_on 'Assign rooms'
        assign_rooms_to_members(group.suite.rooms, group.members)
        expect(page).to have_content('Successfully assigned rooms')
      end
    end
  end

  def assign_rooms_to_members(rs, ms)
    select rs.first.number_with_type,
           from: "room_assignment_room_id_for_#{ms.first.id}"
    select rs.last.number_with_type,
           from: "room_assignment_room_id_for_#{ms.last.id}"
    click_on 'Proceed to confirmation'
    click_on 'Confirm room assignments'
  end

  def update_room_assignments(rs, ms)
    select rs.last.number_with_type,
           from: "room_assignment_room_id_for_#{ms.first.id}"
    select rs.first.number_with_type,
           from: "room_assignment_room_id_for_#{ms.last.id}"
    click_on 'Update room assignments'
  end
end
