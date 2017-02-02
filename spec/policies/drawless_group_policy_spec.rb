# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DrawlessGroupPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :new? do
      it { is_expected.not_to permit(user, DrawlessGroup) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :new? do
      it { is_expected.not_to permit(user, DrawlessGroup) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    let(:group) { FactoryGirl.build_stubbed(:group) }
    permissions :new? do
      it { is_expected.to permit(user, DrawlessGroup) }
    end
    context 'full group' do
      before { allow(group).to receive(:locked?).and_return(true) }
      permissions :select_suite? do
        it { is_expected.to permit(user, group) }
      end
    end
    context 'not full group' do
      before { allow(group).to receive(:locked?).and_return(false) }
      permissions :select_suite? do
        it { is_expected.not_to permit(user, group) }
      end
    end
  end
end
