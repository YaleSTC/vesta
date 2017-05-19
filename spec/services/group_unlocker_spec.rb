# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupUnlocker do
  describe '#unlock' do
    describe 'success' do
      shared_examples 'unlocks groups' do
        it 'returns a success flash' do
          expect(described_class.unlock(group: group)[:msg].keys).to \
            eq([:success])
        end
        it 'updates the group status' do
          described_class.unlock(group: group)
          expect(group.reload).to be_full
        end
      end

      it_behaves_like 'unlocks groups' do
        let(:group) { FactoryGirl.create(:locked_group) }
      end
      it_behaves_like 'unlocks groups' do
        let(:group) { FactoryGirl.create(:finalizing_group) }
      end
    end

    context 'failure' do
      let(:group) { FactoryGirl.create(:open_group) }

      it 'returns an error flash' do
        expect(described_class.unlock(group: group)[:msg].keys).to eq([:error])
      end
      it 'does not change the group status' do
        old_status = group.status
        described_class.unlock(group: group)
        expect(group.reload.status).to eq(old_status)
      end
    end
  end
end
