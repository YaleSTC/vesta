# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  # This tests inherited functionality from ApplicationMailer
  let(:user) { FactoryGirl.build_stubbed(:user) }

  it 'sends a multipart email(html and text)' do
    message = described_class.new_user_confirmation(user: user)
    expect(message.body.parts.collect(&:content_type))
      .to match(['text/plain; charset=UTF-8', 'text/html; charset=UTF-8'])
  end
end
