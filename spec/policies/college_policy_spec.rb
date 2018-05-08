# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/RepeatedExample

RSpec.describe CollegePolicy do
  subject { described_class }

  let(:superuser) do
    instance_spy('user', admin?: true, superuser?: true, superadmin?: true)
  end
  let(:admin) do
    instance_spy('user', admin?: true, superuser?: false, superadmin?: false)
  end
  let(:non_admin) do
    instance_spy('user', admin?: false, superuser?: false, superadmin?: false)
  end
  let(:college) { build_stubbed(:college) }

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

  permissions :access? do
    context 'user is not in the college' do
      before do
        allow(non_admin).to receive(:college_id).and_return(1)
        allow(admin).to receive(:college_id).and_return(1)
        allow(college).to receive(:id).and_return(2)
      end

      it { is_expected.to permit(superuser, college) }
      it { is_expected.not_to permit(admin, college) }
      it { is_expected.not_to permit(non_admin, college) }
    end

    context 'user is in the college' do
      before do
        allow(non_admin).to receive(:college_id).and_return(1)
        allow(admin).to receive(:college_id).and_return(1)
        allow(college).to receive(:id).and_return(1)
      end

      it { is_expected.to permit(superuser, college) }
      it { is_expected.to permit(admin, college) }
      it { is_expected.to permit(non_admin, college) }
    end
  end
end
