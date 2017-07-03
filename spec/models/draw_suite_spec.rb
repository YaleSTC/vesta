# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawSuite do
  describe 'associations' do
    subject { described_class.new }

    it { is_expected.to belong_to(:draw) }
    it { is_expected.to belong_to(:suite) }
  end
end
