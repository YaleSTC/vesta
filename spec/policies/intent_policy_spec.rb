# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IntentPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :report?, :import?, :export? do
      it { is_expected.not_to permit(user) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :report?, :export? do
      it { is_expected.to permit(user) }
    end

    permissions :import? do
      it { is_expected.not_to permit(user) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :report?, :export? do
      it { is_expected.to permit(user) }
    end
  end
end
