# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:user) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:intent) }
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to belong_to(:group) }
  end
  describe '#name' do
    it 'defaults to first name' do
      name = 'Sydney'
      user = FactoryGirl.build_stubbed(:user, first_name: name)
      expect(user.name).to eq(name)
    end
    it 'is preferred name if set' do
      name = 'Syd'
      user = FactoryGirl.build_stubbed(:user, preferred_name: name)
      expect(user.name).to eq(name)
    end
  end
  describe '#full_name' do
    it 'is the name and last name' do
      full_name = 'Sydney Young'
      user = FactoryGirl.build_stubbed(:user, last_name: 'Young')
      allow(user).to receive(:name).and_return('Sydney')
      expect(user.full_name).to eq(full_name)
    end
  end
  describe '#legal_name' do
    it 'is the first, middle, and last name' do
      legal = 'First Middle Last'
      user = FactoryGirl.build_stubbed(:user, first_name: 'First',
                                              middle_name: 'Middle',
                                              last_name: 'Last')
      expect(user.legal_name).to eq(legal)
    end
  end
end
