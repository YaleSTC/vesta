# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }
  let(:other_user) { FactoryGirl.build_stubbed(:user) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show?, :update?, :edit?, :edit_intent?, :update_intent? do
      it { is_expected.to permit(user, user) }
    end
    permissions :show?, :create?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index? do
      it { is_expected.not_to permit(user, User) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :update?, :edit?, :edit_intent?, :update_intent? do
      it { is_expected.to permit(user, user) }
    end
    permissions :show?, :create?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index? do
      it { is_expected.not_to permit(user, User) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :show?, :create?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.to permit(user, other_user) }
    end
    permissions :index? do
      it { is_expected.to permit(user, User) }
    end
  end
end
