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
    it { is_expected.to have_many(:memberships) }
    it { is_expected.to have_one(:group).through(:membership) }
  end

  describe 'CAS username' do
    context 'when CAS is used' do
      subject(:user) { FactoryGirl.build(:user, username: 'foo') }
      before { allow(User).to receive(:cas_auth?).and_return(true) }
      it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
      it { is_expected.to validate_presence_of(:username) }

      it 'downcases before saving' do
        user.update(username: 'FOO')
        expect(user.username).to eq('foo')
      end
    end

    context 'when CAS is not used' do
      subject { FactoryGirl.build(:user) }
      it { is_expected.not_to validate_presence_of(:username) }
    end
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

  describe '.cas_auth?' do
    it 'returns true if the CAS_BASE_URL env variable is set' do
      allow(User).to receive(:env?).with('CAS_BASE_URL').and_return(true)
      expect(User.cas_auth?).to be_truthy
    end
    it 'returns false if the CAS_BASE_URL env variable is not set' do
      allow(User).to receive(:env?).with('CAS_BASE_URL').and_return(false)
      expect(User.cas_auth?).to be_falsey
    end
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

  describe '#full_name_with_intent' do
    it 'is the full name with the intent in parentheses' do
      full_name_with_intent = 'Sydney Young (on campus)'
      user = FactoryGirl.build_stubbed(:user, first_name: 'Sydney',
                                              last_name: 'Young',
                                              intent: 'on_campus')
      expect(user.full_name_with_intent).to eq(full_name_with_intent)
    end
  end

  describe '#pretty_intent' do
    it 'is the intent not in snake case' do
      user = FactoryGirl.build_stubbed(:user, intent: 'on_campus')
      expect(user.pretty_intent).to eq('on campus')
    end
  end

  describe '#group' do
    it 'returns nil if no accepted membership' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, draw: group.draw)
      Membership.create(user: user, group: group, status: 'requested')
      expect(user.reload.group).to be_nil
    end
    it 'returns the group of the accepted membership' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, draw: group.draw)
      Membership.create(user: user, group: group, status: 'accepted')
      expect(user.reload.group).to eq(group)
    end
  end

  describe '#membership' do
    it 'returns nil if no accepted membership' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, draw: group.draw)
      Membership.create(user: user, group: group, status: 'requested')
      expect(user.reload.membership).to be_nil
    end
    it 'returns the accepted membership' do
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, draw: group.draw)
      m = Membership.create(user: user, group: group, status: 'accepted')
      expect(user.reload.membership).to eq(m)
    end
  end

  describe '#remove_draw' do
    it 'backs up the current draw_id to old_draw_id' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.remove_draw
      expect(result.old_draw_id).to eq(123)
    end
    it 'removes the draw_id' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.remove_draw
      expect(result.draw_id).to be_nil
    end
    it 'changes the intent to undeclared' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: 1234,
                                              intent: 'on_campus')
      result = user.remove_draw
      expect(result.intent).to eq('undeclared')
    end
    it 'does not change old_draw_id if draw_id is nil' do
      user = FactoryGirl.build_stubbed(:user, draw_id: nil, old_draw_id: 1234)
      result = user.remove_draw
      expect(result).to eq(user)
    end
  end

  describe '#restore_draw' do
    it 'copies old_draw_id to draw_id' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.restore_draw
      expect(result.draw_id).to eq(1234)
    end
    it 'sets old_draw_id to nil' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.restore_draw
      expect(result.old_draw_id).to eq(nil)
    end
    it 'sets the intent to undeclared' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: 1234,
                                              intent: 'on_campus')
      result = user.restore_draw
      expect(result.intent).to eq('undeclared')
    end
    it 'does nothing if old_draw_id is nil' do
      user = FactoryGirl.build_stubbed(:user, draw_id: 123, old_draw_id: nil)
      result = user.restore_draw
      expect(result).to eq(user)
    end
  end
end
