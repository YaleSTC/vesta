# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups, RSpec/RepeatedExample
# rubocop:disable RSpec/ScatteredSetup
require 'rails_helper'

RSpec.describe DrawPolicy do
  subject { described_class }

  let(:draw) { FactoryGirl.build_stubbed(:draw) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :show? do
      context 'not draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.to permit(user, draw) }
      end
      context 'draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
    permissions :destroy?, :edit?, :update?, :activate?, :oversubscription?,
                :toggle_size_lock?, :start_lottery?, :lottery_confirmation?,
                :start_selection?, :bulk_on_campus?, :reminder?, :results?,
                :lock_all_sizes?, :prune? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :new?, :create? do
      it { is_expected.not_to permit(user, Draw) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Draw) }
    end

    permissions :intent_reminder? do
      before do
        allow(draw).to receive(:intent_deadline).and_return(Time.zone.today)
        allow(draw).to receive(:pre_lottery?).and_return(true)
      end
      it { is_expected.not_to permit(user, draw) }
    end

    permissions :locking_reminder? do
      before do
        allow(draw).to receive(:locking_deadline).and_return(Time.zone.today)
        allow(draw).to receive(:pre_lottery?).and_return(true)
      end
      it { is_expected.not_to permit(user, draw) }
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
      it { is_expected.to permit(user, draw) }
    end

    permissions :group_export? do
      context 'when the draw is not lottery_or_later' do
        before { allow(draw).to receive(:lottery_or_later?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when the draw is lottery_or_later' do
        before { allow(draw).to receive(:lottery_or_later?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :show?, :toggle_size_lock?, :group_report? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :edit?, :update?, :destroy?, :activate?,
                :oversubscription?, :start_lottery?,
                :lottery_confirmation?, :start_selection?, :bulk_on_campus?,
                :lock_all_sizes?, :prune? do
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
      context 'no intent deadline' do
        before { allow(draw).to receive(:intent_deadline).and_return(nil) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'before/on intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.today)
        end
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :locking_reminder? do
      before { allow(draw).to receive(:pre_lottery?).and_return(true) }
      context 'no locking deadline' do
        before do
          allow(draw).to receive(:locking_deadline).and_return(nil)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'before/on locking deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.today)
        end
        it { is_expected.to permit(user, draw) }
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

    permissions :group_export? do
      context 'when the draw is not lottery_or_later' do
        before { allow(draw).to receive(:lottery_or_later?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when the draw is lottery_or_later' do
        before { allow(draw).to receive(:lottery_or_later?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :show?, :edit?, :update?, :destroy?, :toggle_size_lock?,
                :lock_all_sizes?, :group_report? do
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

    permissions :start_lottery?, :lottery_confirmation?, :oversubscription? do
      context 'when draw is pre_lottery' do
        before { allow(draw).to receive(:pre_lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:pre_lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
    end

    permissions :prune? do
      context 'when prelottery and oversubscribed' do
        let(:draw_report) do
          allow(draw).to receive_messages(pre_lottery?: true)
          DrawReport.new(draw).tap do |d|
            allow(d).to receive_messages(oversubscribed?: true)
          end
        end

        it { is_expected.to permit(user, draw_report) }
      end
      context 'when prelottery and not oversubscribed' do
        let(:draw_report) do
          allow(draw).to receive_messages(pre_lottery?: true)
          DrawReport.new(draw).tap do |d|
            allow(d).to receive_messages(oversubscribed?: false)
          end
        end

        it { is_expected.not_to permit(user, draw_report) }
      end
      context 'when not prelottery and oversubscribed' do
        let(:draw_report) do
          allow(draw).to receive_messages(pre_lottery?: false)
          DrawReport.new(draw).tap do |d|
            allow(d).to receive_messages(oversubscribed?: true)
          end
        end

        it { is_expected.not_to permit(user, draw_report) }
      end
    end

    permissions :start_selection? do
      context 'when draw is not lottery' do
        before { allow(draw).to receive(:lottery?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'when draw is lottery' do
        before { allow(draw).to receive(:lottery?).and_return(true) }
        it { is_expected.to permit(user, draw) }
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
      context 'no intent deadline' do
        before { allow(draw).to receive(:intent_deadline).and_return(nil) }
        it { is_expected.not_to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'before/on intent deadline' do
        before do
          allow(draw).to receive(:intent_deadline)
            .and_return(Time.zone.today)
        end
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :locking_reminder? do
      before { allow(draw).to receive(:pre_lottery?).and_return(true) }
      context 'no locking deadline' do
        before do
          allow(draw).to receive(:locking_deadline).and_return(nil)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'after intent deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.yesterday)
        end
        it { is_expected.not_to permit(user, draw) }
      end
      context 'before/on locking deadline' do
        before do
          allow(draw).to receive(:locking_deadline)
            .and_return(Time.zone.today)
        end
        it { is_expected.to permit(user, draw) }
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

    permissions :group_export? do
      context 'when the draw is not lottery_or_later' do
        before { allow(draw).to receive(:lottery_or_later?).and_return(false) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when the draw is lottery_or_later' do
        before { allow(draw).to receive(:lottery_or_later?).and_return(true) }
        it { is_expected.to permit(user, draw) }
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
