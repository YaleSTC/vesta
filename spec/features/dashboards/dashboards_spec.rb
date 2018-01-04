# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Dashboards' do
  context 'admin' do
    it 'renders' do
      create_draws
      log_in FactoryGirl.create(:admin)
      expect(page).to have_content('Vesta')
    end

    def create_draws
      FactoryGirl.create(:draw_with_members, status: 'draft')
      FactoryGirl.create(:oversubscribed_draw, status: 'pre_lottery')
      FactoryGirl.create(:draw_in_lottery)
      FactoryGirl.create(:draw_in_selection)
      # TODO: results draw
    end
  end

  context 'student' do
    shared_examples 'renders' do
      it do
        log_in student
        expect(page).to have_content('Vesta')
      end
    end

    context 'with draw' do
      context 'with deadlines' do
        it_behaves_like 'renders' do
          let(:student) do
            FactoryGirl.create(:student_in_draw).tap do |s|
              s.draw.update(intent_deadline: Time.zone.tomorrow,
                            locking_deadline: Time.zone.tomorrow + 1.day)
            end
          end
        end
      end
    end

    context 'without group' do
      it_behaves_like 'renders' do
        let(:student) { FactoryGirl.create(:student_in_draw) }
      end
    end
    context 'with group no suite' do
      it_behaves_like 'renders' do
        let(:student) { FactoryGirl.create(:group).leader }
      end
    end
    context 'with suite no room' do
      it_behaves_like 'renders' do
        let(:student) { FactoryGirl.create(:group_with_suite).leader }
      end
    end
    context 'with room' do
      it_behaves_like 'renders' do
        let(:student) do
          g = FactoryGirl.create(:group_with_suite)
          s = g.leader
          s.update(room: g.suite.rooms.first)
          s
        end
      end
    end
  end
end
