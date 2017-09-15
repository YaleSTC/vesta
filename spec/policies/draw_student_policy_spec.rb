# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawStudentPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :edit?, :update?, :bulk_assign? do
      it { is_expected.not_to permit(user, :draw_student) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :edit?, :update?, :bulk_assign? do
      it { is_expected.not_to permit(user, :draw_student) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :edit?, :update?, :bulk_assign? do
      it { is_expected.to permit(user, :draw_student) }
    end
  end
end
