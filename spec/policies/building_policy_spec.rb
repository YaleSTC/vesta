# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BuildingPolicy do
  subject { described_class }
  let(:building) { FactoryGirl.build_stubbed(:building) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show? do
      it { is_expected.to permit(user, building) }
    end
    permissions :create?, :destroy?, :edit?, :update?, :index? do
      it { is_expected.not_to permit(user, building) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :index?, :show?, :edit?, :update? do
      it { is_expected.to permit(user, building) }
    end
    permissions :create?, :destroy? do
      it { is_expected.not_to permit(user, building) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :index?, :show?, :edit?, :update?, :create?, :destroy? do
      it { is_expected.to permit(user, building) }
    end
  end
end
