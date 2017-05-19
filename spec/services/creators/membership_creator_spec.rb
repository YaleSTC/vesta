# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipCreator do
  context 'success' do
    it 'creates a membership object' do
      expect(described_class.create!(**params_hash)[:membership]).to \
        be_instance_of(Membership)
    end
    it 'sets a success message in the flash' do
      expect(described_class.create!(**params_hash)[:msg]).to \
        have_key(:success)
    end
    # rubocop:disable RSpec/InstanceVariable
    def params_hash
      @group ||= FactoryGirl.create(:open_group)
      @user ||= FactoryGirl.build(:student, intent: 'on_campus',
                                            draw: @group.draw)
      { group: @group, user: @user, status: 'requested' }
    end
    # rubocop:enable RSpec/InstanceVariable
  end

  it 'does not create when given invalid params' do
    params = { user: nil, group: nil }
    expect(described_class.create!(**params)[:redirect_object]).to be_nil
  end
  it 'returns the membership even if invalid' do
    params = { user: nil, group: nil }
    expect(described_class.create!(**params)[:membership]).to \
      be_instance_of(Membership)
  end
end
