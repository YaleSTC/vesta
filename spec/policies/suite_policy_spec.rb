# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SuitePolicy do
  subject { described_class }
  let(:suite) { FactoryGirl.build_stubbed(:suite) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show?, :index? do
      it { is_expected.to permit(user, suite) }
    end
    permissions :create?, :destroy?, :update? do
      it { is_expected.not_to permit(user, suite) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :index?, :show?, :update? do
      it { is_expected.to permit(user, suite) }
    end
    permissions :create?, :destroy? do
      it { is_expected.not_to permit(user, suite) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :index?, :show?, :update?, :create?, :destroy?, :edit_tags? do
      it { is_expected.to permit(user, suite) }
    end
  end
end
