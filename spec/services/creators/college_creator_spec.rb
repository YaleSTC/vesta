# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollegeCreator do
  describe '#create!' do
    context 'success' do
      let(:params) do
        instance_spy('ActionController::Parameters', to_h: valid_params)
      end
      let(:su) { create(:user, role: 'superuser') }

      it 'creates a college' do
        expect do
          described_class.create!(params: params, user_for_access: su)
        end.to change { College.count }.by(1)
      end
      it 'returns the college object' do
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:college]).to be_instance_of(College)
      end
      it 'returns a success message' do
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:msg]).to have_key(:success)
      end
      it 'returns nil as the redirect object' do
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets the path to be the new college URL' do
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:path]).to eq("http://#{result[:college].host}/")
      end
      it 'creates the superuser in the new college' do
        result = described_class.create!(params: params, user_for_access: su)
        result[:college].activate!
        expect(User.where(email: su.email).count).to eq(1)
      end
      it 'switches back to the original tenant' do
        original_college = College.current
        described_class.create!(params: params, user_for_access: su)
        expect(College.current).to eq(original_college)
      end
    end

    context 'failure' do
      it 'sets :redirect_object to nil' do
        params = instance_spy('ActionController::Parameters', to_h: {})
        su = create(:user, role: 'superuser')
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns the invalid college' do
        params = instance_spy('ActionController::Parameters', to_h: {})
        su = create(:user, role: 'superuser')
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:college]).to be_instance_of(College)
      end
      it 'returns an error message' do
        params = instance_spy('ActionController::Parameters', to_h: {})
        su = create(:user, role: 'superuser')
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:msg]).to have_key(:error)
      end
      it 'checks that the superuser is a superuser' do
        params = instance_spy('ActionController::Parameters',
                              to_h: valid_params)
        su = create(:user, role: 'admin')
        result = described_class.create!(params: params, user_for_access: su)
        expect(result[:redirect_object]).to be_nil
      end
    end
  end

  def valid_params
    {
      name: 'College', subdomain: 'newcollege', dean: 'John Smith',
      admin_email: 'john@smith.com'
    }
  end
end
