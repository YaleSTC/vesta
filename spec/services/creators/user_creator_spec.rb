# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserCreator do
  describe '.create!' do
    it 'calls :create! on an instance of UserCreator' do
      params = instance_spy('Hash')
      user_creator = mock_user_creator(params)
      described_class.create!(params)
      expect(user_creator).to have_received(:create!)
    end
  end

  describe '#create!' do
    context 'success' do
      it 'returns a valid user' do
        params = instance_spy('ActionController::Parameters',
                              to_h: valid_params)
        result = described_class.create!(params)
        expect(result[:object]).to be_an_instance_of(User)
      end
      it 'returns a success message' do
        params = instance_spy('ActionController::Parameters',
                              to_h: valid_params)
        result = described_class.create!(params)
        expect(result[:msg]).to have_key(:success)
      end
      it 'sends a confirmation e-mail' do
        params = instance_spy('ActionController::Parameters',
                              to_h: valid_params)
        mailer = instance_spy('user_mailer')
        described_class.new(params, mailer).create!
        expect(mailer).to have_received(:new_user_confirmation)
      end

      context 'without CAS' do # rubocop:disable RSpec/NestedGroups
        before { allow(User).to receive(:cas_auth?).and_return(false) }
        it 'assigns a random password to the user' do
          params = instance_spy('ActionController::Parameters',
                                to_h: valid_params)
          result = described_class.create!(params)
          expect(result[:object].password).not_to be_empty
        end
      end
      # 2017/01/29: this test currently fails because stubbing out
      # User.cas_auth? doesn't change how the User class was loaded (without
      # CAS), and so it's still running password validations. Even switching to
      # any_instance_of doesn't help because it has to do with when Rails loads
      # the User class, and same goes with using an ENV wrapper as we did in
      # Reservations. Leaving it pending for now.
      context 'with CAS' do # rubocop:disable RSpec/NestedGroups
        before { allow(User).to receive(:cas_auth?).and_return(true) }
        xit 'does not assign a password to the user' do
          params = instance_spy('ActionController::Parameters',
                                to_h: valid_params)
          result = described_class.create!(params)
          expect(result[:object].password).to be_empty
        end
      end
    end

    context 'failure' do
      it 'returns the invalid user' do
        params = instance_spy('ActionController::Parameters', to_h: {})
        result = described_class.create!(params)
        expect(result[:object]).to be_nil
      end
      it 'returns an error message' do
        params = instance_spy('ActionController::Parameters', to_h: {})
        result = described_class.create!(params)
        expect(result[:msg]).to have_key(:error)
      end
      it 'does not send a confirmation e-mail' do
        params = instance_spy('ActionController::Parameters', to_h: {})
        mailer = instance_spy('UserMailer')
        described_class.new(params, mailer).create!
        expect(mailer).not_to have_received(:new_user_confirmation)
      end
    end
  end

  def mock_user_creator(params)
    instance_spy('UserCreator').tap do |user_creator|
      allow(UserCreator).to receive(:new).with(params).and_return(user_creator)
    end
  end

  def valid_params
    {
      first_name: 'John', last_name: 'Smith', gender: 'male', role: 'admin',
      email: 'john@smith.com', username: 'foo'
    }
  end
end
