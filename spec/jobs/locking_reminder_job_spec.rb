# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LockingReminderJob, type: :job do
  let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }
  let(:user) { instance_spy('user') }
  let(:draw) do
    instance_spy('draw', locking_deadline: 'date').tap do |d|
      allow(d.students).to receive(:where)
        .with(draw_memberships: { intent: %w(on_campus undeclared) })
        .and_return([user])
    end
  end

  it 'sends locking reminders to on_campus/undeclared users in the draw' do
    allow(StudentMailer).to receive(:locking_reminder)
      .with(user: user, locking_deadline: draw.locking_deadline).and_return(msg)
    described_class.perform_now(draw: draw)
    expect(StudentMailer).to have_received(:locking_reminder).once
  end

  it 'sends an intent reminder copy to admins' do
    admin = create(:admin)
    allow(StudentMailer).to receive(:locking_reminder).and_return(msg)
    described_class.perform_now(draw: draw)
    expect(StudentMailer).to have_received(:locking_reminder)
      .with(user: admin, locking_deadline: draw.locking_deadline)
  end
end
