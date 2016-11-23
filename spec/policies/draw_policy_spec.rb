# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DrawPolicy do
  subject { described_class }
  let(:draw) { FactoryGirl.build_stubbed(:draw) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :create?, :destroy?, :update?, :index? do
      it { is_expected.not_to permit(user, draw) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :update? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :create?, :destroy?, :index? do
      it { is_expected.not_to permit(user, draw) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :index?, :show?, :update?, :create?, :destroy? do
      it { is_expected.to permit(user, draw) }
    end
  end
end
