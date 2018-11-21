# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBuilder do
  # rubocop:disable RSpec/NestedGroups
  describe '#build' do
    shared_examples 'success' do |overwrite|
      it 'returns instance of User class' do
        result = described_class.build(id_attr: 'foo', overwrite: overwrite)
        expect(result[:user]).to be_instance_of(User)
      end
      it 'returns unpersisted record' do
        result = described_class.build(id_attr: 'foo', overwrite: overwrite)
        expect(result[:user]).not_to be_persisted
      end
      it 'looks up profile data' do
        querier = mock_profile_querier(first_name: 'John')
        result = described_class.new(id_attr: 'foo',
                                     querier: querier, overwrite: overwrite)
                                .build
        expect(result[:user][:first_name]).to eq('John')
      end
      it 'assigns a role' do
        result = described_class.build(id_attr: 'foo', role: 'rep',
                                       overwrite: overwrite)
        expect(result[:user].role).to eq('rep')
      end
      it 'returns a success flash' do
        result = described_class.build(id_attr: 'foo', overwrite: overwrite)
        expect(result[:msg]).to have_key(:success)
      end
      it 'returns action: new' do
        result = described_class.build(id_attr: 'foo', overwrite: overwrite)
        expect(result[:action]).to eq('new')
      end

      context 'with CAS' do
        before { allow(User).to receive(:cas_auth?).and_return(true) }
        it 'sets the username to the username' do
          result = described_class.build(id_attr: 'foo', overwrite: overwrite)
          expect(result[:user].username).to eq('foo')
        end
        it 'does not set the email' do
          result = described_class.build(id_attr: 'foo', overwrite: overwrite)
          expect(result[:user].email).to be_empty
        end
      end

      context 'without CAS' do
        it 'sets the email to the username' do
          result = described_class.build(id_attr: 'foo', overwrite: overwrite)
          expect(result[:user].email).to eq('foo')
        end
        it 'assigns a random password' do
          allow(User).to receive(:random_password).and_return('password')
          result = described_class.build(id_attr: 'foo', overwrite: overwrite)
          expect(result[:user].password).to eq('password')
        end
        it 'assigns the password confirmation' do
          result = described_class.build(id_attr: 'foo', overwrite: overwrite)
          expect(result[:user].password_confirmation).to \
            eq(result[:user].password)
        end
      end
    end

    shared_examples 'failure' do |overwrite|
      it 'returns an error flash' do
        user_spy = instance_spy('ActiveRecord::Relation', count: 1)
        allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        result = described_class.build(id_attr: 'foo', overwrite: false)
        expect(result[:msg]).to have_key(:error)
      end
      it 'returns action: build' do
        user_spy = instance_spy('ActiveRecord::Relation', count: 1)
        allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        result = described_class.build(id_attr: 'foo', overwrite: false)
        expect(result[:action]).to eq('build')
      end
      it 'giving a bad role returns an error flash' do
        result = described_class.build(id_attr: 'foo', role: 'foo',
                                       overwrite: overwrite)
        expect(result[:msg]).to have_key(:error)
      end
    end

    context 'with overwrite disabled' do
      it_behaves_like 'success', false
      it_behaves_like 'failure', false

      context 'without CAS, taken email' do
        before do
          user_spy = instance_spy('ActiveRecord::Relation', count: 1)
          allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        end

        it 'returns new instance of User with random password' do
          expected_hash = User.new.attributes
          expected_hash.delete('encrypted_password')
          result = described_class.build(id_attr: 'foo', overwrite: false)
          expect(result[:user].attributes).to include(expected_hash)
        end
      end
    end

    context 'with overwrite enabled' do
      context 'without existing user' do
        it_behaves_like 'success', true
        it_behaves_like 'failure', true
      end

      context 'with existing user' do
        let(:user) { instance_spy('User', username: 'foo') }

        before do
          allow(User).to receive(:find_by).and_return(user)
          allow(User).to receive(:cas_auth?).and_return(false)
        end

        it "updates existing user's role" do
          described_class.new(id_attr: 'foo', role: 'graduated',
                              overwrite: true)
                         .build
          expect(user).to have_received(:role=).with('graduated').once
        end

        it "updates existing user's college" do
          allow(College).to receive(:current).and_return('Gilliam')
          described_class.new(id_attr: 'foo', role: 'graduated',
                              overwrite: true)
                         .build
          expect(user).to have_received(:college=).with('Gilliam').once
        end

        it "doesn't change the current user's password" do
          allow(User).to receive(:random_password).and_return('password')
          described_class.new(id_attr: 'foo', role: 'graduated',
                              overwrite: true)
                         .build
          expect(User).not_to have_received(:random_password)
        end
      end
    end
  end

  context '#exists?' do
    context 'without CAS' do
      it 'returns true if that identifying attribute is already taken' do
        user_spy = instance_spy('ActiveRecord::Relation', count: 1)
        allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        expect(described_class.new(id_attr: 'foo')).to be_exists
      end
      it 'returns false if that identifying attribute is not already taken' do
        user_spy = instance_spy('ActiveRecord::Relation', count: 0)
        allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        expect(described_class.new(id_attr: 'foo')).not_to be_exists
      end
    end
  end

  def mock_user_builder(params_hash)
    instance_spy('UserBuilder').tap do |user_builder|
      allow(UserBuilder).to receive(:new).with(params_hash)
                                         .and_return(user_builder)
    end
  end

  def mock_profile_querier(**profile_data)
    class_spy('IdrProfileQuerier').tap do |pq|
      allow(pq).to receive(:query).and_return(profile_data)
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
