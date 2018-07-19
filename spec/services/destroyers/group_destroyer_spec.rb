# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupDestroyer do
  it 'sucessfully destroys a group' do
    group = create(:full_group)
    destroyer = described_class.new(group: group)
    expect(destroyer.destroy[:redirect_object]).to be_nil
  end
  it 'fails if destroy fails' do
    group = instance_spy('Group', destroy: false)
    destroyer = described_class.new(group: group)
    expect(destroyer.destroy[:redirect_object]).to eq(group)
  end
  context 'on disbanding' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }
    let(:group) { create(:full_group) }

    it 'notifies members' do
      allow(StudentMailer).to receive(:disband_notification).and_return(msg)
      destroyer = described_class.new(group: group)
      destroyer.destroy
      expect(StudentMailer).to \
        have_received(:disband_notification).exactly(group.memberships_count)
    end
  end
end
