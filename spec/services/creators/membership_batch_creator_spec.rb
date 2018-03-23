# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipBatchCreator do
  it 'creates many memberships' do # rubocop:disable RSpec/ExampleLength
    batch = described_class.new(user_ids: users.map { |u| u.id.to_s },
                                **params_hash)
    allow(MembershipCreator).to receive(:create!)
    allow(batch).to receive(:build_result)
    batch.run
    users.each do |u|
      expect(MembershipCreator).to have_received(:create!)
        .with(**params_hash.to_h.merge(user: u))
    end
  end

  describe 'builds a flash message' do
    it 'contains success and error' do
      result = described_class.run(user_ids: users.map { |u| u.id.to_s },
                                   **params_hash)
      expect(result[:msg].keys).to include(:success, :error)
    end
  end

  context 'too many users' do
    it "doesn't create any memberships" do # rubocop:disable RSpec/ExampleLength
      batch = described_class.new(user_ids: users.map { |u| u.id.to_s },
                                  **params_hash)
      allow(MembershipCreator).to receive(:create!)
      allow(params_hash[:group]).to receive(:size).and_return(1)
      batch.run
      expect(MembershipCreator).not_to have_received(:create!)
    end
  end

  context 'redirect object' do
    it 'is added when there are no failures' do
      users.last.update!(intent: 'on_campus')
      result = described_class.run(user_ids: users.map { |u| u.id.to_s },
                                   **params_hash)
      expect(result[:redirect_object].map(&:class)).to eq([Draw, Group])
    end
    it 'is not added when there are failures' do
      result = described_class.run(user_ids: users.map { |u| u.id.to_s },
                                   **params_hash)
      expect(result[:redirect_object]).to be_nil
    end
  end

  # rubocop:disable RSpec/InstanceVariable
  def params_hash
    @group ||= FactoryGirl.create(:open_group, size: 3)
    { group: @group, status: 'requested' }
  end

  def users
    # generate params hash
    params_hash
    @users ||= [FactoryGirl.create(:student, intent: 'on_campus',
                                             draw: @group.draw),
                FactoryGirl.create(:student, intent: 'undeclared',
                                             draw: @group.draw)]
  end
  # rubocop:enable RSpec/InstanceVariable
end
