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

  # rubocop:disable RSpec/ExampleLength
  it 'destroys a dependent membership on destruction' do
    user = FactoryGirl.create(:student, intent: 'on_campus')
    FactoryGirl.create(:drawless_group, leader: user)
    membership_id = user.membership.id
    user.destroy
    expect { Membership.find(membership_id) }.to \
      raise_error(ActiveRecord::RecordNotFound)
  end
  # rubocop:enable RSpec/ExampleLength

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
