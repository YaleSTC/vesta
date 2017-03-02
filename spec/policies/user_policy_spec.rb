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
  end
end
