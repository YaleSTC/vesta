# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'basic validations' do
    subject { build(:user) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:intent) }
    it { is_expected.to belong_to(:college) }
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to have_one(:membership) }
    it { is_expected.to have_many(:memberships) }
    it { is_expected.to have_one(:group).through(:membership) }
    it { is_expected.to have_one(:room_assignment) }
    it { is_expected.to have_one(:room).through(:room_assignment) }
    it { is_expected.to delegate_method(:draw_name).to(:draw).as(:name) }
    it { is_expected.to delegate_method(:group_name).to(:group).as(:name) }
    it { is_expected.to delegate_method(:room_number).to(:room).as(:number) }
    it { is_expected.to delegate_method(:suite_number).to(:group) }
    it { is_expected.to delegate_method(:lottery_number).to(:group) }
  end

  describe 'class_year' do
    let(:user) { build(:user) }

    it 'is required for students' do
      user.role = 'student'
      expect(user).to validate_presence_of(:class_year)
    end

    it 'is required for reps' do
      user.role = 'rep'
      expect(user).to validate_presence_of(:class_year)
    end

    it 'is not required for admins' do
      user.role = 'admin'
      expect(user).not_to validate_presence_of(:class_year)
    end

    it 'is not required for superusers' do
      user.role = 'superuser'
      expect(user).not_to validate_presence_of(:class_year)
    end
  end

  describe 'college_id' do
    let(:user) { build(:user) }

    it 'is required for students' do
      user.role = 'student'
      expect(user).to validate_presence_of(:college_id)
    end

    it 'is required for reps' do
      user.role = 'rep'
      expect(user).to validate_presence_of(:college_id)
    end

    it 'is required for admins' do
      user.role = 'admin'
      expect(user).to validate_presence_of(:college_id)
    end

    it 'is not required for superadmins' do
      user.role = 'superadmin'
      expect(user).not_to validate_presence_of(:college_id)
    end

    it 'is not required for superusers' do
      user.role = 'superuser'
      expect(user).not_to validate_presence_of(:college_id)
    end
  end

  describe 'other validations' do
    xit 'checks to make sure an assigned room belongs to the right group'

    context 'tos_accepted' do
      it 'can be accepted' do
        user = create(:user, tos_accepted: nil)
        user.tos_accepted = Time.current
        user.save!
        expect(user).to be_valid
      end
      it 'is frozen once accepted' do
        user = create(:user, tos_accepted: Time.current)
        user.tos_accepted = Time.current
        expect { user.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end
      it 'raises an error if changed once accepted' do
        user = create(:user, tos_accepted: Time.current)
        user.update(tos_accepted: Time.current)
        expect(user.errors[:base])
          .to include('Terms of Service acceptance cannot be changed')
      end
    end
  end

  describe 'CAS username' do
    context 'when CAS is used' do
      subject(:user) { build(:user, username: 'foo') }

      before { allow(User).to receive(:cas_auth?).and_return(true) }
      it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
      it { is_expected.to validate_presence_of(:username) }

      it 'downcases before saving' do
        user.update(username: 'FOO')
        expect(user.username).to eq('foo')
      end
    end

    context 'when CAS is not used' do
      subject { build(:user) }

      it { is_expected.not_to validate_presence_of(:username) }
    end
  end

  # rubocop:disable RSpec/ExampleLength
  it 'destroys a dependent membership on destruction' do
    user = create(:student, intent: 'on_campus')
    group = create(:drawless_group, size: 2)
    m = Membership.create!(user: user, group: group).id
    user.destroy
    expect { Membership.find(m) }.to \
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

  describe '.login_attr' do
    it 'returns :username if CAS auth is enabled' do
      allow(described_class).to receive(:cas_auth?).and_return(true)
      expect(described_class.login_attr).to eq(:username)
    end
    it 'returns :email if CAS auth is not enabled' do
      allow(described_class).to receive(:cas_auth?).and_return(false)
      expect(described_class.login_attr).to eq(:email)
    end
  end

  describe '.random_password' do
    it 'returns a 12 character token from Devise by default' do
      random = 'abcdefghijkl'
      allow(Devise).to receive(:friendly_token).with(12)
                                               .and_return(random)
      expect(described_class.random_password).to eq(random)
    end

    it 'allows for the length to be specified' do
      random = 'abcdefghijklmno'
      allow(Devise).to receive(:friendly_token).with(15)
                                               .and_return(random)
      expect(described_class.random_password(15)).to eq(random)
    end
  end

  describe '#name' do
    it 'is the first name' do
      name = 'Sydney'
      user = build_stubbed(:user, first_name: name)
      expect(user.name).to eq(name)
    end
  end

  describe '#full_name' do
    it 'is the name and last name' do
      full_name = 'Sydney Young'
      user = build_stubbed(:user, first_name: 'Sydney', last_name: 'Young')
      expect(user.full_name).to eq(full_name)
    end
  end

  describe '#full_name_with_intent' do
    it 'is the full name with the intent in parentheses' do
      full_name_with_intent = 'Sydney Young (on campus)'
      user = build_stubbed(:user, first_name: 'Sydney', last_name: 'Young',
                                  intent: 'on_campus')
      expect(user.full_name_with_intent).to eq(full_name_with_intent)
    end
  end

  describe '#pretty_intent' do
    it 'is the intent not in snake case' do
      user = build_stubbed(:user, intent: 'on_campus')
      expect(user.pretty_intent).to eq('on campus')
    end
  end

  describe '#group' do
    it 'returns nil if no accepted membership' do
      group = create(:open_group)
      user = create(:student, draw: group.draw)
      Membership.create(user: user, group: group, status: 'requested')
      expect(user.reload.group).to be_nil
    end
    it 'returns the group of the accepted membership' do
      group = create(:open_group)
      user = create(:student, draw: group.draw)
      Membership.create(user: user, group: group, status: 'accepted')
      expect(user.reload.group).to eq(group)
    end
  end

  describe '#membership' do
    it 'returns nil if no accepted membership' do
      group = create(:open_group)
      user = create(:student, draw: group.draw)
      Membership.create(user: user, group: group, status: 'requested')
      expect(user.reload.membership).to be_nil
    end
    it 'returns the accepted membership' do
      group = create(:open_group)
      user = create(:student, draw: group.draw)
      m = Membership.create(user: user, group: group, status: 'accepted')
      expect(user.reload.membership).to eq(m)
    end
  end

  describe '#remove_draw' do
    it 'backs up the current draw_id to old_draw_id' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.remove_draw
      expect(result.old_draw_id).to eq(123)
    end
    it 'removes the draw_id' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.remove_draw
      expect(result.draw_id).to be_nil
    end
    it 'changes the intent to undeclared' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234,
                                  intent: 'on_campus')
      result = user.remove_draw
      expect(result.intent).to eq('undeclared')
    end
    it 'does not change old_draw_id if draw_id is nil' do
      user = build_stubbed(:user, draw_id: nil, old_draw_id: 1234)
      result = user.remove_draw
      expect(result).to eq(user)
    end
  end

  describe '#restore_draw' do
    it 'copies old_draw_id to draw_id' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.restore_draw
      expect(result.draw_id).to eq(1234)
    end
    it 'sets draw_id to nil if old_draw_id and draw_id are equal' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 123)
      result = user.restore_draw
      expect(result.draw_id).to be_nil
    end
    it 'sets old_draw_id to nil by default' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.restore_draw
      expect(result.old_draw_id).to be_nil
    end
    it 'optionally saves draw_id to old_draw_id' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234)
      result = user.restore_draw(save_current: true)
      expect(result.old_draw_id).to eq(123)
    end
    it 'sets the intent to undeclared' do
      user = build_stubbed(:user, draw_id: 123, old_draw_id: 1234,
                                  intent: 'on_campus')
      result = user.restore_draw
      expect(result.intent).to eq('undeclared')
    end
  end

  describe '#leader_of?' do
    it 'returns true when user leader of group' do
      user = build_stubbed(:user)
      group = instance_spy('Group', leader: user)
      expect(user.leader_of?(group)).to be_truthy
    end
    it 'returns false when user not leader of group' do
      user = build_stubbed(:user)
      group = instance_spy('Group')
      expect(user.leader_of?(group)).to be_falsey
    end
  end

  describe '#admin?' do
    let(:user) { build(:user) }

    it 'returns true for superusers' do
      user.role = 'superuser'
      expect(user.admin?).to be(true)
    end
    it 'returns true for superadmins' do
      user.role = 'superadmin'
      expect(user.admin?).to be(true)
    end
    it 'returns true for admins' do
      user.role = 'admin'
      expect(user.admin?).to be(true)
    end
    it 'returns false for reps' do
      user.role = 'rep'
      expect(user.admin?).to be(false)
    end
    it 'returns false for students' do
      user.role = 'student'
      expect(user.admin?).to be(false)
    end
  end

  describe '#superadmin?' do
    let(:user) { build(:user) }

    it 'returns true for superusers' do
      user.role = 'superuser'
      expect(user.superadmin?).to be(true)
    end
    it 'returns true for superadmins' do
      user.role = 'superadmin'
      expect(user.superadmin?).to be(true)
    end
    it 'returns false for admins' do
      user.role = 'admin'
      expect(user.superadmin?).to be(false)
    end
    it 'returns false for reps' do
      user.role = 'rep'
      expect(user.superadmin?).to be(false)
    end
    it 'returns false for students' do
      user.role = 'student'
      expect(user.superadmin?).to be(false)
    end
  end

  describe '#login_attr' do
    let(:user) { build(:user) }

    it 'returns the username if CAS is being used' do
      allow(User).to receive(:cas_auth?).and_return(true)
      expect(user.login_attr).to eq(user.username)
    end
    it 'returns the email if CAS is not being used' do
      allow(User).to receive(:cas_auth?).and_return(false)
      expect(user.login_attr).to eq(user.email)
    end
  end
end
