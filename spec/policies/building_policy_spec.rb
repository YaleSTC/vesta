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
    permissions :destroy?, :edit?, :update? do
      it { is_expected.not_to permit(user, building) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Building) }
    end
    permissions :new?, :create? do
      it { is_expected.not_to permit(user, Building) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :show? do
      it { is_expected.to permit(user, building) }
    end
    permissions :destroy?, :edit?, :update? do
      it { is_expected.not_to permit(user, building) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Building) }
    end
    permissions :new?, :create? do
      it { is_expected.not_to permit(user, Building) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :new?, :create?, :index? do
      it { is_expected.to permit(user, Building) }
    end
    permissions :show?, :edit?, :update?, :destroy? do
      it { is_expected.to permit(user, building) }
    end
  end
end
