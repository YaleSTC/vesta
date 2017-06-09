# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsPolicy do
  subject { described_class }

  let(:admin) { instance_spy('user', admin?: true) }
  let(:non_admin) { instance_spy('user', admin?: false) }

  permissions :show? do
    it { is_expected.to permit(admin, :results) }
    it { is_expected.not_to permit(non_admin, :results) }
  end
end
