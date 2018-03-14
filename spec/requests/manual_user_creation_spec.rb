# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manual user creation', type: :request do
  let(:admin) { create(:admin) }
  let(:attrs) { %i(first_name last_name role email username class_year) }

  before do
    post user_session_path,
         params: { user: { email: admin.email, password: 'passw0rd' } }
  end

  it 'prevents non-superusers from creating superusers' do
    user_params = attributes_for(:user).slice(*attrs).merge(role: 'superuser')
    post users_path, params: { user: user_params }
    expect(User.last.role).to eq('student')
  end

  it 'still allows admins to create regular admins' do
    user_params = attributes_for(:user).slice(*attrs).merge(role: 'admin')
    post users_path, params: { user: user_params }
    expect(User.last.role).to eq('admin')
  end

  it 'still allows superusers to create superusers' do
    admin.update!(role: 'superuser')
    user_params = attributes_for(:user).slice(*attrs).merge(role: 'superuser')
    post users_path, params: { user: user_params }
    expect(User.last.role).to eq('superuser')
  end
end
