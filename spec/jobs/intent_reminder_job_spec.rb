# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IntentReminderJob, type: :job do
  let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }
  let(:user) { instance_spy('user') }
  let(:draw) do
    instance_spy('draw', intent_deadline: 'date').tap do |d|
      allow(d.students).to receive(:where).with(intent: %w(undeclared))
                                          .and_return([user])
    end
  end

  it 'sends intent reminders to undeclared users in the draw' do
    allow(StudentMailer).to receive(:intent_reminder)
      .with(user: user).and_return(msg)
    described_class.perform_now(draw: draw)
    expect(StudentMailer).to have_received(:intent_reminder).once
  end
end
