# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Masquerades Controller', type: :request do
  let(:admin) { create(:admin) }
  let(:student) { create(:student) }

  it 'adds admin id to session' do
    masquerade!
    expect(session[:admin_id]).to eq(admin.id)
  end

  it 'changes the current user in the session' do
    masquerade!
    expect(session['warden.user.user.key'][0][0]).to eq(student.id)
  end

  it 'safely clears the session' do
    masquerade!
    delete end_masquerades_path
    expect(session[:admin_id]).to be_nil
  end

  it 'reverts the current user in the session' do
    masquerade!
    delete end_masquerades_path
    expect(session['warden.user.user.key'][0][0]).to eq(admin.id)
  end

  def masquerade!
    sign_in admin
    get new_user_masquerade_path(student.id)
  end
end
