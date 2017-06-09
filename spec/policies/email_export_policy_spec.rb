# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailExportPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :new?, :create? do
      it { is_expected.not_to permit(user, EmailExport) }
    end
  end

  context 'rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :new?, :create? do
      it { is_expected.to permit(user, EmailExport) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :new?, :create? do
      it { is_expected.to permit(user, EmailExport) }
    end
  end
end
