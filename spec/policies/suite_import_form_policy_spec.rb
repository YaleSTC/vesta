# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteImportFormPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { build_stubbed(:user, role: 'student') }

    permissions :create? do
      it { is_expected.not_to permit(user, SuiteImportForm) }
    end
  end

  context 'housing rep' do
    let(:user) { build_stubbed(:user, role: 'rep') }

    permissions :create? do
      it { is_expected.not_to permit(user, SuiteImportForm) }
    end
  end

  context 'admin' do
    let(:user) { build_stubbed(:user, role: 'admin') }

    permissions :create? do
      it { is_expected.to permit(user, SuiteImportForm) }
    end
  end
end
