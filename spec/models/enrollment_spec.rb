# frozen_string_literal: true

require 'rails_helper'
require 'support/fake_profile_querier'

RSpec.describe Enrollment do
  context 'validations' do
    subject { described_class.new(ids: '') }

    it { is_expected.to validate_presence_of(:ids) }
  end

  describe '#enroll' do
    context 'data fetch failure' do
      it 'correctly creates the valid user' do
        ids = %w(id1 badqueryid).join(', ')
        result = described_class.enroll(ids: ids, querier: FakeProfileQuerier)
        expect(result[:users]).to eq([User.first])
      end
      it 'notes the success of the valid user' do
        ids = %w(id1 badqueryid).join(', ')
        result = described_class.enroll(ids: ids, querier: FakeProfileQuerier)
        expect(result[:msg][:success]).to include('id1')
      end
      it 'correctly creates the valid user role' do
        ids = %w(id1 badqueryid).join(', ')
        result = described_class.enroll(ids: ids, role: 'rep',
                                        querier: FakeProfileQuerier)
        expect(result[:users].first.role).to eq('rep')
      end
      it 'notes the failure of the invalid query' do
        ids = %w(id1 badqueryid).join(', ')
        result = described_class.enroll(ids: ids, querier: FakeProfileQuerier)
        expect(result[:msg][:alert]).to include('badqueryid')
      end
      it 'renders the result action as long as there is a valid id' do
        ids = %w(id1 badqueryid).join(', ')
        result = described_class.enroll(ids: ids, querier: FakeProfileQuerier)
        expect(result[:action]).to eq('results')
      end
      it 'renders the new action if there is no valid id' do
        ids = %w(badqueryid).join(', ')
        result = described_class.enroll(ids: ids, querier: FakeProfileQuerier)
        expect(result[:action]).to eq('new')
      end
    end
    context 'save failure' do
      it 'notes the failure of the invalid id' do
        ids = %w(id1 invalidid).join(', ')
        result = described_class.enroll(ids: ids, querier: FakeProfileQuerier)
        expect(result[:msg][:error]).to include('invalidid')
      end
    end
  end

  describe '#username?' do
    it 'returns true if the first successful user has a username' do
      enrollment = described_class.new
      user_hash = { user: FactoryGirl.build_stubbed(:user, username: 'foo') }
      allow(enrollment).to receive(:successes).and_return([user_hash])
      expect(enrollment.username?).to be_truthy
    end
    it 'returns false if the first successful user does not have a username' do
      enrollment = described_class.new
      allow(enrollment).to receive(:successes)
      user_hash = { user: FactoryGirl.build_stubbed(:user, username: nil) }
      allow(enrollment).to receive(:successes).and_return([user_hash])
      expect(enrollment.username?).to be_falsey
    end
    it 'returns false if there are no successful users' do
      enrollment = described_class.new
      expect(enrollment.username?).to be_falsey
    end
  end
end
