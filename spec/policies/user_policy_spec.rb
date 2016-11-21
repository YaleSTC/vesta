# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }
  let(:other_user) { FactoryGirl.build_stubbed(:user) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show?, :update? do
      it { is_expected.to permit(user, user) }
    end
    permissions :show?, :create?, :destroy?, :update?, :index? do
      it { is_expected.not_to permit(user, other_user) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :update? do
      it { is_expected.to permit(user, user) }
    end
    permissions :show?, :create?, :destroy?, :update?, :index? do
      it { is_expected.not_to permit(user, other_user) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :index?, :show?, :update?, :create?, :destroy? do
      it { is_expected.to permit(user, other_user) }
    end
  end
end
