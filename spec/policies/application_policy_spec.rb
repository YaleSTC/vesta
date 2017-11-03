# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :superuser_dash? do
      it { is_expected.not_to permit(user) }
    end
  end

  context 'rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :superuser_dash? do
      it { is_expected.not_to permit(user) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :superuser_dash? do
      it { is_expected.not_to permit(user) }
    end
  end

  context 'superuser' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'superuser') }

    permissions :superuser_dash? do
      it { is_expected.to permit(user) }
    end
  end
end
