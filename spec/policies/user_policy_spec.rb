# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }
  let(:other_user) { FactoryGirl.build_stubbed(:user) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show? do
      it { is_expected.to permit(user, user) }
    end
    permissions :edit?, :update? do
      it { is_expected.not_to permit(user, user) }
    end
    context 'draw in pre-lottery status' do
      before do
        allow(user).to receive(:draw)
          .and_return(instance_spy('draw', pre_lottery?: true))
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.to permit(user, user) }
      end
    end
    context 'draw not pre-lottery status' do
      before do
        allow(user).to receive(:draw)
          .and_return(instance_spy('draw', pre_lottery?: false))
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.not_to permit(user, user) }
      end
    end
    permissions :show?, :create?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index?, :build? do
      it { is_expected.not_to permit(user, User) }
    end
    permissions :draw_info? do
      context 'other user is admin' do
        before { allow(other_user).to receive(:admin?).and_return(true) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is not in draw' do
        before { allow(other_user).to receive(:draw_id).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'non-admin in draw' do
        before do
          allow(other_user).to receive(:admin?).and_return(false)
          allow(other_user).to receive(:draw_id).and_return(1)
        end
        it { is_expected.to permit(user, other_user) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show? do
      it { is_expected.to permit(user, user) }
    end
    permissions :edit?, :update? do
      it { is_expected.not_to permit(user, user) }
    end
    context 'draw in pre-lottery status' do
      before do
        allow(user).to receive(:draw)
          .and_return(instance_spy('draw', pre_lottery?: true))
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.to permit(user, user) }
      end
    end
    context 'draw not pre-lottery status' do
      before do
        allow(user).to receive(:draw)
          .and_return(instance_spy('draw', pre_lottery?: false))
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.not_to permit(user, user) }
      end
    end
    permissions :show?, :create?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index?, :build? do
      it { is_expected.not_to permit(user, User) }
    end
    permissions :draw_info? do
      context 'other user is admin' do
        before { allow(other_user).to receive(:admin?).and_return(true) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is not in draw' do
        before { allow(other_user).to receive(:draw_id).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'non-admin in draw' do
        before do
          allow(other_user).to receive(:admin?).and_return(false)
          allow(other_user).to receive(:draw_id).and_return(1)
        end
        it { is_expected.to permit(user, other_user) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :show?, :create?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.to permit(user, other_user) }
    end
    permissions :index?, :build? do
      it { is_expected.to permit(user, User) }
    end
    permissions :draw_info? do
      context 'other user is admin' do
        before { allow(other_user).to receive(:admin?).and_return(true) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is not in draw' do
        before { allow(other_user).to receive(:draw_id).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'non-admin in draw' do
        before do
          allow(other_user).to receive(:admin?).and_return(false)
          allow(other_user).to receive(:draw_id).and_return(1)
        end
        it { is_expected.to permit(user, other_user) }
      end
    end
  end
end
