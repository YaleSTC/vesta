# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_and_belong_to_many(:suites) }
  end
end
