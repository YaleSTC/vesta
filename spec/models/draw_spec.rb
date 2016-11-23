# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Draw, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:students) }
    it { is_expected.to have_and_belong_to_many(:suites) }
  end
end
