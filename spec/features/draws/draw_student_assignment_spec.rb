# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw student assignment' do
  let(:draw) { create(:draw) }

  before { log_in create(:admin) }
  describe 'bulk adding' do
    before { create_pair(:student, class_year: 2016) }
    it 'can be performed' do
      visit draw_path(draw)
      click_on 'Add or edit students'
      bulk_assign_students(2016)
      msg = 'Students successfully updated'
      expect(page).to have_css('.flash-success', text: msg)
    end

    def bulk_assign_students(year)
      visit edit_draw_students_path(draw)
      select year.to_s, from: 'draw_students_update_class_year'
      click_on 'Assign students'
    end
  end

  shared_examples 'assignment querying with' do |qtype|
    let(:form_entry) { 'draw_student_assignment_form_login' }

    it 'form text responds to query type' do
      allow(User).to receive(:login_attr).and_return(qtype)
      visit edit_draw_students_path(draw)
      expect(page).to have_content("Add/Remove by #{qtype}")
    end

    describe 'single user adding' do
      let!(:fake_student) { { username: 'bar', email: 'bar@m.com' } }
      let!(:student) { create(:student, username: 'foo', email: 'foo@m.com') }
      let!(:student_in_group) do
        create(:student, username: 'stu', email: 'stu@m.com')
      end

      before do
        allow(User).to receive(:login_attr).and_return(qtype)
        create(:group, leader: student_in_group)
      end

      it 'can be performed' do
        visit edit_draw_students_path(draw, student)
        fill_in form_entry, with: student.send(qtype)
        click_on 'Process'
        msg = "#{student.full_name} successfully added"
        expect(page).to have_css('.flash-success', text: msg)
      end

      it 'displays user not found error if user is not imported' do
        visit edit_draw_students_path(draw)
        fill_in form_entry, with: fake_student[qtype]
        click_on 'Process'
        msg = "Username cannot be found. Maybe you haven't imported them yet?"
        expect(page).to have_css('.flash-error', text: msg)
      end

      it 'displays user in group error if user is already in a group' do
        visit edit_draw_students_path(draw)
        fill_in form_entry, with: student_in_group.send(qtype)
        click_on 'Process'
        msg = 'cannot be added to this draw because they are already in a group'
        expect(page).to have_css('.flash-error', text: msg)
      end
    end

    describe 'single user removing' do
      let(:student) { create(:student, username: 'foo', email: 'foo@m.com') }

      before do
        allow(User).to receive(:login_attr).and_return(qtype)
        draw.students << student
      end

      it 'can be performed' do
        visit edit_draw_students_path(draw, student)
        remove_user(login: student.send(qtype))
        msg = "#{student.full_name} successfully removed"
        expect(page).to have_css('.flash-success', text: msg)
      end

      it 'is case insensitive' do
        visit edit_draw_students_path(draw)
        fill_in form_entry, with: student.send(qtype)
        click_on 'Process'
        msg = "Username cannot be found. Maybe you haven't imported them yet?"
        expect(page).not_to have_css('.flash-error', text: msg)
      end

      def remove_user(login:)
        fill_in form_entry, with: login
        select 'Remove'
        click_on 'Process'
      end
    end
  end

  it_behaves_like 'assignment querying with', :email
  it_behaves_like 'assignment querying with', :username
end
