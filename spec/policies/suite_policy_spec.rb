# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SuitePolicy do
  subject { described_class }
  let(:suite) { FactoryGirl.build_stubbed(:suite) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show? do
      it { is_expected.to permit(user, suite) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Suite) }
    end
    permissions :new?, :create?, :destroy?, :edit?, :update?, :deactivate?,
                :activate? do
      it { is_expected.not_to permit(user, suite) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :edit?, :update?, :deactivate?, :activate? do
      it { is_expected.to permit(user, suite) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Suite) }
    end
    permissions :new?, :create?, :destroy? do
      it { is_expected.not_to permit(user, suite) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :show?, :edit?, :update?, :destroy?, :deactivate?, :activate? do
      it { is_expected.to permit(user, suite) }
    end
    permissions :new?, :create?, :index? do
      it { is_expected.to permit(user, Suite) }
    end
  end
end
