# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupLocker do
  describe '#lock' do
    shared_examples 'success' do
      it 'returns a success flash' do
        expect(described_class.lock(group: group)[:msg].keys).to eq([:success])
      end
      it 'updates the group status to locked' do
        described_class.lock(group: group)
        expect(group.reload).to be_locked
      end

      context 'locking email' do
        let(:msg) do
          instance_spy(ActionMailer::MessageDelivery, deliver_later: 1)
        end

        it 'is sent' do
          group = create(:full_group, size: 2)
          allow(StudentMailer).to receive(:group_locked).and_return(msg)
          described_class.lock(group: group)
          expect(StudentMailer).to \
            have_received(:group_locked).exactly(group.memberships_count)
        end
      end
    end

    shared_examples 'failure' do
      it 'returns an error flash' do
        expect(described_class.lock(group: group)[:msg].keys).to eq([:error])
      end
      it 'does not change the group status' do
        old_status = group.status
        described_class.lock(group: group)
        expect(group.reload.status).to eq(old_status)
      end
    end

    context 'some memberships locked' do
      it_behaves_like 'success' do
        let(:group) do
          create(:finalizing_group, size: 3).tap do |group|
            group.full_memberships.last.update(locked: true)
          end
        end
      end
    end

    context 'group not full' do
      it_behaves_like 'failure' do
        let(:group) { create(:open_group) }
      end
    end
  end
end
