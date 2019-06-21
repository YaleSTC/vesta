# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'basic validations' do
    subject { build(:user) }

    it { is_expected.to have_many(:draw_memberships) }
    it { is_expected.to have_many(:draws).through(:draw_memberships) }
    it { is_expected.to have_one(:draw_membership).conditions(active: true) }
    it { is_expected.to have_one(:draw).through(:draw_membership) }
    it { is_expected.to have_many(:memberships).through(:draw_memberships) }
    it do
      is_expected.to have_many(:active_memberships).through(:draw_membership)
    end
    it { is_expected.to have_one(:membership).through(:draw_membership) }
    it { is_expected.to have_one(:room_assignment).through(:draw_membership) }
    it { is_expected.to have_one(:room).through(:draw_membership) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:student_id) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to belong_to(:college) }

    it { is_expected.to delegate_method(:draw_name).to(:draw).as(:name) }
    it { is_expected.to delegate_method(:group_name).to(:group).as(:name) }
    it { is_expected.to delegate_method(:room_number).to(:room).as(:number) }
    it { is_expected.to delegate_method(:suite_number).to(:group) }
    it { is_expected.to delegate_method(:lottery_number).to(:group) }
    it { is_expected.to delegate_method(:intent).to(:draw_membership) }
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
    context 'tos_accepted' do
      it 'can be accepted' do
        user = create(:user, tos_accepted: nil)
        user.tos_accepted = Time.current
        user.save!
        expect(user).to be_valid
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
    dm = create(:draw_membership, draw: nil)
    group = create(:drawless_group, size: 2)
    m = Membership.create!(draw_membership: dm, group: group).id
    dm.user.destroy
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

  describe '#full_name' do
    it 'is the first name and last name' do
      full_name = 'Sydney Young'
      user = build_stubbed(:user, first_name: 'Sydney', last_name: 'Young')
      expect(user.full_name).to eq(full_name)
    end
  end

  describe '#group' do
    it 'returns nil if no accepted membership' do
      group = create(:open_group)
      user = create(:student_in_draw, draw: group.draw)
      create(:membership, user: user, group: group, status: 'requested')
      expect(user.reload.group).to be_nil
    end
    it 'returns the group of the accepted membership' do
      group = create(:open_group)
      user = create(:student_in_draw, draw: group.draw)
      create(:membership, user: user, group: group, status: 'accepted')
      expect(user.reload.group).to eq(group)
    end
  end

  describe '#membership' do
    it 'returns nil if no accepted membership' do
      group = create(:open_group)
      user = create(:student_in_draw, draw: group.draw)
      create(:membership, user: user, group: group, status: 'requested')
      expect(user.reload.membership).to be_nil
    end
    it 'returns the accepted membership' do
      group = create(:open_group)
      user = create(:student_in_draw, draw: group.draw)
      m = create(:membership, user: user, group: group, status: 'accepted')
      expect(user.reload.membership).to eq(m)
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
