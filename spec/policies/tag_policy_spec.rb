# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TagPolicy do
  subject { described_class }
  let(:tag) { FactoryGirl.build_stubbed(:tag) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :show?, :create?, :destroy?, :update?, :index? do
      it { is_expected.not_to permit(user, tag) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :show?, :create?, :destroy?, :update?, :index? do
      it { is_expected.not_to permit(user, tag) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :index?, :show?, :update?, :create?, :destroy? do
      it { is_expected.to permit(user, tag) }
    end
  end
end
