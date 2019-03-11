# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SidUpdaterJob, type: :job do
  context 'when sid is returned' do
    # querying with this returns a hash with 'student_id' as one of the keys
    let(:user) { instance_spy('user', update!: true, login_attr: 'foo') }

    it 'updates the user' do
      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('QUERIER')
                                .and_return('FakeProfileQuerier')
      described_class.perform_now(user: user)
      expect(user).to have_received(:update!)
    end
  end

  context 'when sid is not returned' do
    # querying with an id of 'badqueryid' returns an empty hash
    let(:user) { instance_spy('user', update!: true, login_attr: 'badqueryid') }

    it 'does not update the user' do
      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('QUERIER')
                                .and_return('FakeProfileQuerier')
      described_class.perform_now(user: user)
      expect(user).not_to have_received(:update!)
    end
  end
end
