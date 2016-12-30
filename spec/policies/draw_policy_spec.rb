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
    permissions :create?, :destroy?, :update? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :index? do
      it { is_expected.not_to permit(user, Draw) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :update? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :create?, :destroy? do
      it { is_expected.not_to permit(user, draw) }
    end
    permissions :index? do
      it { is_expected.not_to permit(user, Draw) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :show?, :update?, :create?, :destroy? do
      it { is_expected.to permit(user, draw) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Draw) }
    end
  end
end
