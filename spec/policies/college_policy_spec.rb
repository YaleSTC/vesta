# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollegePolicy do
  subject { described_class }

  let(:admin) { instance_spy('user', admin?: true) }
  let(:non_admin) { instance_spy('user', admin?: false) }
  let(:college) { FactoryGirl.build_stubbed(:college) }

  permissions :new?, :create? do
    it { is_expected.to permit(admin, described_class) }
    it { is_expected.not_to permit(non_admin, described_class) }
  end

  permissions :show?, :edit?, :update?, :destroy? do
    it { is_expected.to permit(admin, college) }
    it { is_expected.not_to permit(non_admin, college) }
  end
end
