# frozen_string_literal: true

require 'rails_helper'

describe UserUpdater do
  describe 'admins can edit themselves' do
    it 'returns the edited user object' do
      params = { email: 'newemail@email.com' }
      user = create_admin(params)
      updater = described_class.new(user: user, params: params,
                                    editing_self: true)
      expect(updater.update[:record][:email]).to eq('newemail@email.com')
    end
  end
  describe 'admins can edit others' do
    it 'can update the role' do
      params = { role: 'rep' }
      user = create_admin(params)
      updater = described_class.new(user: user, params: params,
                                    editing_self: false)
      expect(updater.update[:record][:role]).to eq('rep')
    end
  end

  describe 'failed update' do
    it 'returns an error if admins try to demote themselves' do
      params = { role: 'rep' }
      user = create_admin(params)
      updater = described_class.new(user: user, params: params,
                                    editing_self: true)
      expect(updater.update[:msg]).to have_key(:error)
    end
  end

  def create_admin(params)
    FactoryGirl.build_stubbed(:admin).tap do |user|
      response = user.assign_attributes(params)
      allow(user).to receive(:update!).with(params).and_return(response)
      allow(user).to receive(:admin?).and_return(true)
    end
  end
end
