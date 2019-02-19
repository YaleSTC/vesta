# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawSuite do
  describe 'associations' do
    subject { described_class.new }

    it { is_expected.to belong_to(:draw) }
    it { is_expected.to belong_to(:suite) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:draw) }
    it { is_expected.to validate_presence_of(:suite) }
  end

  describe 'uniqueness constraints' do
    it 'prevent duplicate draw_suites' do
      draw = create(:draw)
      suite = create(:suite)
      draw.suites << suite
      expect { draw.suites << suite }.to \
        raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
