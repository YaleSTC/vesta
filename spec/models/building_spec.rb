# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Building, type: :model do
  describe 'basic validations' do
    subject { build(:building) }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_uniqueness_of(:full_name) }
    it { is_expected.to validate_uniqueness_of(:abbreviation) }
    it { is_expected.to have_many(:suites).dependent(:destroy) }
  end

  describe '#name' do
    it 'returns the building abbreviation if it exists' do
      abbrev = 'ABR'
      building = create(:building, abbreviation: abbrev)
      expect(building.name).to eq(abbrev)
    end

    it 'returns the full name if abbreviation does not exist' do
      building = create(:building)
      expect(building.name).to eq(building.full_name)
    end
  end

  describe '#suites_by_size' do
    xit 'it retrieves all the suites by size in a given building'
  end
end
