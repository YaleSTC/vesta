# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessGroupPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    let(:group) { FactoryGirl.build_stubbed(:drawless_group) }

    before { allow(Group).to receive(:find).and_return(group) }

    permissions :new?, :create? do
      it { is_expected.not_to permit(user, DrawlessGroup) }
    end
    permissions :edit?, :update?, :destroy?, :select_suite?, :lock?, :unlock? do
      it { is_expected.not_to permit(user, group) }
    end
    context 'student not in group' do
      before { allow(group).to receive(:members).and_return([]) }
      permissions :show? do
        it { is_expected.not_to permit(user, group) }
      end
    end
    context 'student in group' do
      before { allow(group).to receive(:members).and_return([user]) }
      permissions :show? do
        it { is_expected.to permit(user, group) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    let(:group) { FactoryGirl.build_stubbed(:drawless_group) }

    before { allow(Group).to receive(:find).and_return(group) }

    permissions :new?, :create? do
      it { is_expected.not_to permit(user, DrawlessGroup) }
    end
    permissions :edit?, :update?, :destroy?, :select_suite?, :lock?, :unlock? do
      it { is_expected.not_to permit(user, group) }
    end
    context 'student not in group' do
      before { allow(group).to receive(:members).and_return([]) }
      permissions :show? do
        it { is_expected.not_to permit(user, group) }
      end
    end
    context 'student in group' do
      before { allow(group).to receive(:members).and_return([user]) }
      permissions :show? do
        it { is_expected.to permit(user, group) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    let(:group) { FactoryGirl.build_stubbed(:drawless_group) }

    before { allow(Group).to receive(:find).and_return(group) }

    permissions :new?, :create? do
      it { is_expected.to permit(user, DrawlessGroup) }
    end
    permissions :show?, :edit?, :update?, :destroy? do
      it { is_expected.to permit(user, group) }
    end
    permissions :lock? do
      context 'lockable group' do
        before do
          allow(group).to receive(:open?).and_return(false)
          allow(group).to receive(:locked?).and_return(false)
        end
        it { is_expected.to permit(user, group) }
      end
      context 'open group' do
        before { allow(group).to receive(:open?).and_return(true) }
        it { is_expected.not_to permit(user, group) }
      end
      context 'locked group' do
        before { allow(group).to receive(:locked?).and_return(true) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    context 'locked group' do
      before { allow(group).to receive(:locked?).and_return(true) }
      permissions :select_suite? do
        it { is_expected.to permit(user, group) }
      end
    end
    context 'not locked group' do
      before { allow(group).to receive(:locked?).and_return(false) }
      permissions :select_suite? do
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :unlock? do
      context 'unlockable group' do
        before { allow(group).to receive(:unlockable?).and_return(true) }
        it { is_expected.to permit(user, group) }
      end
      context 'not unlockable group' do
        before { allow(group).to receive(:unlockable?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end
    end
  end
end
