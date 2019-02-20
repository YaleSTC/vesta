# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Dashboards' do
  context 'admin' do
    it 'renders' do
      create_draws
      log_in create(:admin)
      expect(page).to have_content('Vesta')
    end

    def create_draws
      create(:draw_with_members, status: 'draft')
      create(:oversubscribed_draw, status: 'group_formation')
      create(:draw_in_lottery)
      create(:draw_in_selection)
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
            create(:student_in_draw).tap do |s|
              s.draw.update(intent_deadline: Time.zone.tomorrow,
                            locking_deadline: Time.zone.tomorrow + 1.day)
            end
          end
        end
      end

      context 'when archived' do
        let(:archived_draw) { create(:draw_with_groups) }
        let(:group) { archived_draw.groups.first }
        let(:student) { group.leader }
        let(:active_draw) { create(:draw, status: 'intent_selection') }

        before do
          archived_draw.update!(active: false)
          active_draw.students << student
          log_in student
        end

        it 'shows current draw' do
          visit root_path
          expect(page).to have_link(active_draw.name,
                                    href: draw_path(active_draw))
        end

        it 'does not show old data' do
          visit root_path
          expect(page).not_to \
            have_link(group.name, href: draw_group_path(active_draw, group))
        end
      end
    end

    context 'without group' do
      it_behaves_like 'renders' do
        let(:student) { create(:student_in_draw) }
      end
    end
    context 'with group no suite' do
      it_behaves_like 'renders' do
        let(:student) { create(:group).leader }
      end
    end
    context 'with suite no room' do
      it_behaves_like 'renders' do
        let(:student) { create(:group_with_suite).leader }
      end
    end
    context 'with room' do
      it_behaves_like 'renders' do
        let(:student) do
          g = create(:group_with_suite)
          s = g.leader
          create(:room_assignment, room: g.suite_assignment.suite.rooms.first,
                                   user: s.reload)
          s
        end
      end
    end
  end
end
