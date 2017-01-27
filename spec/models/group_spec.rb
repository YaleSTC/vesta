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
    it { is_expected.to have_many(:memberships) }
    it { is_expected.to have_many(:members).through(:memberships) }
    it { is_expected.not_to allow_value(-1).for(:memberships_count) }
  end

  describe 'size validations' do
    context 'for regular groups' do
      it 'must be available in the draw' do
        group = FactoryGirl.build(:group)
        allow(group.draw).to receive(:suite_sizes).and_return([1])
        group.size = 2
        expect(group.valid?).to be_falsey
      end
    end
    context 'for drawless groups' do
      it 'must be an existing suite size' do
        group = FactoryGirl.build(:drawless_group)
        allow(SuiteSizesQuery).to receive(:call).and_return([1])
        group.size = 2
        expect(group).not_to be_valid
      end
    end
    it 'must not have more members than the size' do
      group = FactoryGirl.create(:full_group, size: 2)
      allow(group.draw).to receive(:suite_sizes).and_return([1, 2])
      group.size = 1
      expect(group.valid?).to be_falsey
    end
  end

  describe 'status validations' do
    it 'can only be locked if the number of members match the size' do
      group = FactoryGirl.build(:open_group)
      group.status = 'locked'
      expect(group.valid?).to be_falsey
    end
    it 'cannot be full when there are less members than the size' do
      group = FactoryGirl.build(:open_group)
      group.status = 'full'
      expect(group.valid?).to be_falsey
    end
    it 'cannot be open when members match the size' do
      group = FactoryGirl.create(:full_group, size: 2)
      group.status = 'open'
      expect(group.valid?).to be_falsey
    end
  end

  it 'destroys dependent memberships on destruction' do
    group = FactoryGirl.create(:drawless_group)
    membership_ids = group.memberships.map(&:id)
    group.destroy
    expect { Membership.find(membership_ids) }.to \
      raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'leader is included as a member' do
    it do
      group = FactoryGirl.create(:group)
      expect(group.members).to include(group.leader)
    end
  end

  describe '#name' do
    it "includes the leader's name" do
      leader = instance_spy('User', name: 'Name')
      group = FactoryGirl.build_stubbed(:group)
      allow(group).to receive(:leader).and_return(leader)
      expect(group.name).to include(leader.name)
    end
  end

  describe '#requests' do
    it 'returns an array of users who have requested to join' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(group: group, user: user, status: 'requested')
      expect(group.requests).to eq([user])
    end
  end

  describe '#invitations' do
    it 'returns an array of users who have been invited to join' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(group: group, user: user, status: 'invited')
      expect(group.invitations).to eq([user])
    end
  end
end
