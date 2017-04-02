# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups, RSpec/RepeatedExample
# rubocop:disable RSpec/ScatteredSetup
require 'rails_helper'

RSpec.describe DrawPolicy do
  subject { described_class }

  let(:draw) { FactoryGirl.build_stubbed(:draw) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :show?, :suite_summary? do
      context 'not draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.to permit(user, draw) }
      end
      context 'draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
    permissions :destroy?, :edit?, :update?, :activate?, :intent_report?,
                :filter_intent_report?, :suites_edit?, :suites_update?,
                :student_summary?, :students_update?, :oversubscription?,
                :toggle_size_lock?, :start_lottery?, :lottery_confirmation?,
                :start_selection?, :bulk_on_campus?, :select_suites?,
                :assign_suites?, :reminder?, :intent_reminder?,
                :locking_reminder?, :lock_all_sizes?, :results? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :new?, :create? do
      it { is_expected.not_to permit(user, Draw) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Draw) }
    end

    permissions :group_actions? do
      context 'non-pre-lottery draw' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'pre-lottery draw' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :intent_actions? do
      it { is_expected.not_to permit(user, draw) }
    end

    permissions :oversub_report? do
      context 'when draw is pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        context 'when draw has suites' do
          before do
            allow(draw).to receive(:suites)
              .and_return([instance_spy('suite')])
          end
          it { is_expected.to permit(user, draw) }
        end
        context 'when draw has no suites' do
          before { allow(draw).to receive(:suites).and_return([]) }
          it { is_expected.not_to permit(user, draw) }
        end
      end
      context 'when draw is not pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :group_report? do
      context 'when draw has groups' do
        before do
          allow(draw).to receive(:groups).and_return([instance_spy('group')])
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'when draw has no groups' do
        before { allow(draw).to receive(:groups).and_return([]) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :show?, :suite_summary?, :intent_report?,
                :filter_intent_report?, :toggle_size_lock? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :edit?, :update?, :destroy?, :activate?, :student_summary?,
                :students_update?, :oversubscription?, :start_lottery?,
                :lottery_confirmation?, :start_selection?, :bulk_on_campus?,
                :lock_all_sizes? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :new?, :create? do
      it { is_expected.not_to permit(user, Draw) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Draw) }
    end
    permissions :group_actions?, :create_new_group? do
      context 'non-pre-lottery draw' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'pre-lottery draw' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :oversubscription? do
      context 'when draw is pre_lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end

      context 'when draw is not pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :intent_actions? do
      it { is_expected.to permit(user, draw) }
    end

    permissions :oversub_report? do
      context 'when draw is pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        context 'when draw has suites' do
          before do
            allow(draw).to receive(:suites)
              .and_return([instance_spy('suite')])
          end
          it { is_expected.to permit(user, draw) }
        end
        context 'when draw has no suites' do
          before { allow(draw).to receive(:suites).and_return([]) }
          it { is_expected.not_to permit(user, draw) }
        end
      end
      context 'when draw is not pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :group_report? do
      context 'when draw has groups' do
        before do
          allow(draw).to receive(:groups).and_return([instance_spy('group')])
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'when draw has no groups' do
        before { allow(draw).to receive(:groups).and_return([]) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :lottery? do
      context 'draw is not in lottery phase' do
        before { allow(draw).to receive(:lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is in lottery phase' do
        before { allow(draw).to receive(:lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :select_suites?, :assign_suites? do
      context 'draw is not in suite selection phase' do
        before { allow(draw).to receive(:suite_selection?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is in suite selection phase' do
        before { allow(draw).to receive(:suite_selection?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :reminder? do
      context 'draw is not in pre_lottery phase' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is in pre_lottery phase' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :intent_reminder? do
      before { allow(draw).to receive(:pre_lottery?).and_return(true) }
      context 'before/on intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.tomorrow)
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'no intent deadline' do
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :locking_reminder? do
      before { allow(draw).to receive(:pre_lottery?).and_return(true) }
      context 'before/on locking deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.today + 3.days)
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.today + 1.day)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.today + 3.days)
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'no intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :results? do
      context 'draw is in results phase' do
        before { allow(draw).to receive(:results?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
      context 'draw is not in results phase' do
        before { allow(draw).to receive(:results?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :show?, :edit?, :update?, :destroy?, :intent_report?,
                :filter_intent_report?, :suite_summary?, :suites_edit?,
                :suites_update?, :student_summary?, :students_update?,
                :toggle_size_lock?, :lock_all_sizes? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :index?, :new?, :create? do
      it { is_expected.to permit(user, Draw) }
    end

    permissions :activate? do
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :group_actions? do
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :start_lottery?, :lottery_confirmation?, :oversubscription?,
                :create_new_group? do
      context 'when draw is pre_lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :start_selection? do
      context 'when draw is in lottery' do
        before do
          allow(draw).to receive(:lottery?).and_return(true)
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'when draw is not in lottery' do
        before do
          allow(draw).to receive(:lottery?).and_return(false)
        end
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :intent_actions? do
      it { is_expected.to permit(user, draw) }
    end

    permissions :oversub_report? do
      context 'when draw is pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        context 'when draw has suites' do
          before do
            allow(draw).to receive(:suites)
              .and_return([instance_spy('suite')])
          end
          it { is_expected.to permit(user, draw) }
        end
        context 'when draw has no suites' do
          before { allow(draw).to receive(:suites).and_return([]) }
          it { is_expected.not_to permit(user, draw) }
        end
      end
      context 'when draw is not pre lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :group_report? do
      context 'when draw has groups' do
        before do
          allow(draw).to receive(:groups).and_return([instance_spy('group')])
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'when draw has no groups' do
        before { allow(draw).to receive(:groups).and_return([]) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :lottery? do
      context 'draw is not in lottery phase' do
        before { allow(draw).to receive(:lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is in lottery phase' do
        before { allow(draw).to receive(:lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :select_suites?, :assign_suites? do
      context 'draw is not in suite selection phase' do
        before { allow(draw).to receive(:suite_selection?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is in suite selection phase' do
        before { allow(draw).to receive(:suite_selection?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :bulk_on_campus? do
      context 'draw is before lottery and has undeclared students' do
        before do
          allow(draw).to receive(:before_lottery?).and_return(true)
          allow(draw).to receive(:all_intents_declared?).and_return(false)
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'draw is before lottery but has no undeclared students' do
        before do
          allow(draw).to receive(:before_lottery?).and_return(true)
          allow(draw).to receive(:all_intents_declared?).and_return(true)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is after lottery' do
        before { allow(draw).to receive(:before_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :reminder? do
      context 'draw is not in pre_lottery phase' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'draw is in pre_lottery phase' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :intent_reminder? do
      before { allow(draw).to receive(:pre_lottery?).and_return(true) }
      context 'before/on intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.tomorrow)
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'no intent deadline' do
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :locking_reminder? do
      before { allow(draw).to receive(:pre_lottery?).and_return(true) }
      context 'before/on locking deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.today + 3.days)
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.today + 1.day)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.today + 3.days)
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.to permit(user, draw) }
      end
      context 'no intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :results? do
      context 'draw is in results phase' do
        before { allow(draw).to receive(:results?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
      context 'draw is not in results phase' do
        before { allow(draw).to receive(:results?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end

  context 'role-agnostic permissions' do
    let(:user) { FactoryGirl.build_stubbed(:user) }

    permissions :selection_metrics? do
      context 'in suite selection' do
        before { allow(draw).to receive(:suite_selection?).and_return(true) }

        context 'user has group and is in draw' do
          before do
            allow(user).to receive(:draw).and_return(draw)
            group = instance_spy('group', present?: true)
            allow(user).to receive(:group).and_return(group)
          end
          it { is_expected.to permit(user, draw) }
        end
        context 'user has no group but is in draw' do
          before do
            allow(user).to receive(:draw).and_return(draw)
            allow(user).to receive(:group).and_return(nil)
          end
          it { is_expected.not_to permit(user, draw) }
        end
        context 'user has a group but is not in draw' do
          before do
            allow(user).to receive(:draw).and_return(nil)
            group = instance_spy('group', present?: true)
            allow(user).to receive(:group).and_return(group)
          end
          it { is_expected.not_to permit(user, draw) }
        end
      end

      context 'not in suite selection' do
        before { allow(draw).to receive(:suite_selection?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end
end
