# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/RepeatedExample

RSpec.describe CollegePolicy do
  subject { described_class }

  let(:superuser) { instance_spy('user', admin?: true, superuser?: true) }
  let(:admin) { instance_spy('user', admin?: true, superuser?: false) }
  let(:non_admin) { instance_spy('user', admin?: false, superuser?: false) }
  let(:college) { FactoryGirl.build_stubbed(:college) }

  permissions :new?, :create? do
    it { is_expected.to permit(superuser, described_class) }
    it { is_expected.not_to permit(admin, described_class) }
    it { is_expected.not_to permit(non_admin, described_class) }
  end

  permissions :show?, :edit?, :update? do
    it { is_expected.to permit(superuser, college) }
    it { is_expected.to permit(admin, college) }
    it { is_expected.not_to permit(non_admin, college) }
  end

  permissions :index? do
    it { is_expected.not_to permit(superuser, described_class) }
    it { is_expected.not_to permit(admin, described_class) }
    it { is_expected.not_to permit(non_admin, described_class) }
  end
end
