# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipCreator do
  context 'success' do
    it 'creates a membership object' do
      expect(described_class.create!(params_hash)[:membership]).to \
        be_instance_of(Membership)
    end
    it 'can create an invited membership' do
      result = described_class.create!(params_hash('invite'))
      expect(result[:membership].status).to eq('invited')
    end
    it 'can create an requested membership' do
      result = described_class.create!(params_hash('request'))
      expect(result[:membership].status).to eq('requested')
    end
    it 'sets a success message in the flash' do
      expect(described_class.create!(params_hash)[:msg]).to \
        have_key(:success)
    end
  end

  it 'does not create when given invalid params' do
    params = { user: nil, group: nil, action: nil }
    expect(described_class.create!(**params)[:redirect_object]).to be_nil
  end
  it 'can create an invited membership' do
    result = described_class.create!(params_hash('foo'))
    expect(result[:redirect_object]).to be_nil
  end
  it 'returns the membership even if invalid' do
    params = { user: nil, group: nil, action: nil }
    expect(described_class.create!(**params)[:membership]).to \
      be_instance_of(Membership)
  end

  describe 'email' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }
    let(:g) { create(:open_group) }

    it 'is sent to leader on request creation' do
      m = described_class.new(user: create(:student, draw: g.draw), group: g,
                              action: 'request')
      allow(StudentMailer).to receive(:requested_to_join_group).and_return(msg)
      m.create!
      expect(StudentMailer).to have_received(:requested_to_join_group)
    end

    it 'is sent to student on invitation creation' do
      m = described_class.new(user: create(:student, draw: g.draw), group: g,
                              action: 'invite')
      allow(StudentMailer).to receive(:invited_to_join_group).and_return(msg)
      m.create!
      expect(StudentMailer).to have_received(:invited_to_join_group)
    end
  end

  # rubocop:disable RSpec/InstanceVariable
  def params_hash(action = 'invite')
    @group ||= create(:open_group)
    @user ||= build(:student, intent: 'on_campus', draw: @group.draw)
    { group: @group, user: @user, action: action }
  end
  # rubocop:enable RSpec/InstanceVariable
end
