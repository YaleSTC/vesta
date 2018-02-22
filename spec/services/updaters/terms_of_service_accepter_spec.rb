# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfServiceAccepter do
  describe 'success' do
    it 'updates the user' do
      user = instance_spy('User', update!: true)
      allow(Time).to receive(:current).and_return('3ish')
      described_class.accept(user: user)
      expect(user).to have_received(:update!).with(tos_accepted: '3ish')
    end
    it 'returns a nil redirect_object' do
      user = instance_spy('User', update!: true)
      result = described_class.accept(user: user)
      expect(result[:redirect_object]).to eq(nil)
    end
    it 'returns a nil action' do
      user = instance_spy('User', update!: true)
      result = described_class.accept(user: user)
      expect(result[:action]).to eq(nil)
    end
    it 'returns a nil path' do
      user = instance_spy('User', update!: true)
      result = described_class.accept(user: user)
      expect(result[:path]).to eq(nil)
    end
    it 'returns a success flash' do
      user = instance_spy('User', update!: true)
      result = described_class.accept(user: user)
      expect(result[:msg]).to have_key(:success)
    end
  end

  describe 'failure' do
    it 'does not update when not given a user' do
      expect(described_class.accept(user: nil)[:msg]).to have_key(:error)
    end
    it 'returns an error flash' do
      user = instance_spy('User')
      allow(user).to receive(:update!).and_raise(error)
      expect(described_class.accept(user: user)[:msg]).to have_key(:error)
    end
    it 'returns a nil redirect_object' do
      user = instance_spy('User')
      allow(user).to receive(:update!).and_raise(error)
      expect(described_class.accept(user: user)[:redirect_object]).to eq(nil)
    end
    it 'redirects to show' do
      user = instance_spy('User')
      allow(user).to receive(:update!).and_raise(error)
      result = described_class.accept(user: user)
      expect(result[:action]).to eq('show')
    end
  end

  def error
    ActiveRecord::RecordInvalid.new(FactoryGirl.build_stubbed(:user))
  end
end
