# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfServicePolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :show? do
      it { is_expected.to permit(user) }
    end
    permissions :accept? do
      context 'tos is already accepted' do
        before do
          user.tos_accepted = Time.current
        end
        it { is_expected.not_to permit(user) }
      end
      context 'tos is not accepted' do
        before do
          user.tos_accepted = nil
        end
        it { is_expected.to permit(user) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :show? do
      it { is_expected.to permit(user) }
    end
    permissions :accept? do
      context 'tos is already accepted' do
        before do
          user.tos_accepted = Time.current
        end
        it { is_expected.not_to permit(user) }
      end
      context 'tos is not accepted' do
        before do
          user.tos_accepted = nil
        end
        it { is_expected.to permit(user) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :show? do
      it { is_expected.to permit(user) }
    end
    permissions :accept? do
      it { is_expected.not_to permit(user) }
    end
  end
end
