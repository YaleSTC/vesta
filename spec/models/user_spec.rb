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
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to have_one(:membership) }
    it { is_expected.to have_one(:group).through(:membership) }
  end
  describe '#name' do
    it 'is the first name' do
      name = 'Sydney'
      user = FactoryGirl.build_stubbed(:user, first_name: name)
      expect(user.name).to eq(name)
    end
  end
  describe '#full_name' do
    it 'is the name and last name' do
      full_name = 'Sydney Young'
      user = FactoryGirl.build_stubbed(:user, first_name: 'Sydney',
                                              last_name: 'Young')
      expect(user.full_name).to eq(full_name)
    end
  end
end
