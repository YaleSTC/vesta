# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentMailer, type: :mailer do
  # This tests inherited functionality from ApplicationMailer
  let(:user) { build_stubbed(:user) }
  let(:draw) { build_stubbed(:draw) }

  it 'prepends [Example] to the subject if the user is an admin' do
    allow(user).to receive(:admin?).and_return(true)
    message = described_class.draw_invitation(user: user, draw: draw)
    expect(message.subject).to include('[Example]')
  end

  it 'does not prepend example if the user is not an admin' do
    allow(user).to receive(:admin?).and_return(false)
    message = described_class.draw_invitation(user: user, draw: draw)
    expect(message.subject).not_to include('[Example]')
  end
end
