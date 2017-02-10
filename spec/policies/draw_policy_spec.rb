# frozen_string_literal: true
# rubocop:disable RSpec/NestedGroups
require 'rails_helper'

RSpec.describe DrawPolicy do
  subject { described_class }
  let(:draw) { FactoryGirl.build_stubbed(:draw) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show?, :suite_summary? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :new?, :create?, :destroy?, :edit?, :update?, :activate?,
                :intent_report?, :filter_intent_report?, :suites_edit?,
                :suites_update? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :index? do
      it { is_expected.not_to permit(user, Draw) }
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

    permissions :intent_summary? do
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.to permit(user, draw) }
      end
    end
    permissions :oversub_report? do
      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
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
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :suite_summary? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :create?, :edit?, :update?, :destroy?, :activate?,
                :intent_report?, :filter_intent_report?, :suites_edit?,
                :suites_update? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :new?, :index? do
      it { is_expected.not_to permit(user, Draw) }
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

    permissions :intent_summary? do
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :oversub_report? do
      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
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
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :show?, :edit?, :update?, :destroy?, :intent_report?,
                :filter_intent_report?, :group_actions?, :suite_summary?,
                :suites_edit?, :suites_update? do
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

    permissions :intent_summary? do
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end

      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
        it { is_expected.to permit(user, draw) }
      end
    end

    permissions :oversub_report? do
      context 'when draw is not a draft' do
        before { allow(draw).to receive(:draft?).and_return(false) }
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
      context 'when draw is a draft' do
        before { allow(draw).to receive(:draft?).and_return(true) }
        it { is_expected.not_to permit(user, draw) }
      end
    end
  end
end
