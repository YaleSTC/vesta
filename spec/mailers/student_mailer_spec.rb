# frozen_string_literal: true

require 'rails_helper'
include MailHelper

RSpec.describe StudentMailer, type: :mailer do
  # This tests inherited functionality from ApplicationMailer
  let(:user) { build_stubbed(:user) }
  let(:draw) { build_stubbed(:draw) }
  let(:college) { build_stubbed(:college) }

  # rubocop:disable Rspec/ExampleLength
  it 'prepends [Example] to the subject if the user is an admin' do
    allow(user).to receive(:admin?).and_return(true)
    message = described_class.draw_invitation(user: user,
                                              intent_locked: draw.intent_locked,
                                              intent_deadline: draw
                                                               .intent_deadline)
    expect(message.subject).to include('[Example]')
  end

  it 'does not prepend example if the user is not an admin' do
    allow(user).to receive(:admin?).and_return(false)
    message = described_class.draw_invitation(user: user,
                                              intent_locked: draw.intent_locked,
                                              intent_deadline: draw
                                                               .intent_deadline)
    expect(message.subject).not_to include('[Example]')
    # rubocop:enable Rspec/ExampleLength
  end

  context 'vesta links' do
    it 'includes a Vesta link in intent reminder email' do
      message = described_class.intent_reminder(user: user, intent_deadline:
        draw.intent_deadline, college: college)
      expect(message.html_part.decoded).to include(root_url(host: college.host))
    end

    it 'includes a Vesta link in group reminder email' do
      message = described_class.locking_reminder(user: user, locking_deadline:
        draw.locking_deadline, college: college)
      expect(message.html_part.decoded).to include(root_url(host: college.host))
    end
  end
end
