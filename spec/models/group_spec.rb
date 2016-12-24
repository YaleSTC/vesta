# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:group) }
    it { is_expected.to validate_presence_of(:size) }
    it { is_expected.to allow_value(1).for(:size) }
    it { is_expected.not_to allow_value(0).for(:size) }
    it { is_expected.not_to allow_value(-1).for(:size) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to belong_to(:leader) }
    it { is_expected.to validate_presence_of(:leader) }
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to validate_presence_of(:draw) }
    it { is_expected.to have_many(:members) }
  end

  describe '#name' do
    it "includes the leader's name" do
      leader = instance_spy('User', name: 'Name')
      group = FactoryGirl.build_stubbed(:group)
      allow(group).to receive(:leader).and_return(leader)
      expect(group.name).to include(leader.name)
    end
  end

  describe 'leader is included as a member' do
    it do
      group = FactoryGirl.create(:group)
      expect(group.members).to include(group.leader)
    end
  end
end
