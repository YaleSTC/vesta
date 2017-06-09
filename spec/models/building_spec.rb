# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Building, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:building) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to have_many(:suites) }
  end

  describe '#suites_by_size' do
    xit 'it retrieves all the suites by size in a given building'
  end
end
