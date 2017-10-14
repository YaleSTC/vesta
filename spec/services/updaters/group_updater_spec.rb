# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupUpdater do
  describe '#update' do
    # rubocop:disable RSpec/ExampleLength
    context 'group is full' do
      it 'deletes memberships for users being removed before updating' do
        group = FactoryGirl.create(:open_group, size: 2)
        to_remove = FactoryGirl.create(:student, intent: 'on_campus',
                                                 draw: group.draw)
        group.members << to_remove
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'remove_ids' => [to_remove.id.to_s] })
        expect { described_class.update(group: group, params: p) }.to \
          change(Membership, :count).by(-1)
      end
    end

    context 'users being added' do
      it 'updates their intent to on_campus if necessary' do
        group = FactoryGirl.create(:open_group, size: 2)
        to_add = FactoryGirl.create(:student, intent: 'undeclared',
                                              draw: group.draw)
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'member_ids' => [to_add.id.to_s] })
        described_class.update(group: group, params: p)
        expect(to_add.reload.intent).to eq('on_campus')
      end
    end

    context 'size is locked' do
      it 'deletes the empty size key from the params' do
        group = FactoryGirl.create(:full_group, size: 2)
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'leader_id' => group.members.last.id.to_s,
                                 'size' => '' })
        result = described_class.update(group: group, params: p)
        expect(result[:msg]).to have_key(:success)
      end
    end

    context 'users being removed' do
      it 'does not remove the leader if passed' do
        group = FactoryGirl.create(:open_group, size: 2)
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'remove_ids' => [group.leader_id.to_s] })
        expect { described_class.update(group: group, params: p) }.not_to \
          change(Membership, :count)
      end
    end
    # rubocop:enable RSpec/ExampleLength
    context 'success' do
      it 'sets to the :redirect_object to the group and draw' do
        group = instance_spy('group', update!: true)
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        result = described_class.update(group: group, params: p)
        expect(result[:redirect_object]).to eq([group.draw, group])
      end
      it 'sets the :group to the group' do
        group = instance_spy('group', update!: true)
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        result = described_class.update(group: group, params: p)
        expect(result[:record]).to eq(group)
      end
      it 'sets a success message' do
        group = instance_spy('group', update!: true)
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        result = described_class.update(group: group, params: p)
        expect(result[:msg]).to have_key(:success)
      end
      it 'can add members and increase the size' do
        group = expandable_group(size: 1)
        user = FactoryGirl.create(:user, draw: group.draw, intent: 'on_campus')
        params = { size: 2, member_ids: [user.id.to_s] }
        described_class.update(group: group, params: params)
        expect(group.members).to include(user)
      end
    end
    context 'failure' do
      let!(:group) do
        FactoryGirl.build_stubbed(:group).tap do |g|
          memberships = instance_spy('ActiveRecord::CollectionProxy',
                                     where: true)
          allow(g).to receive(:memberships).and_return(memberships)
          allow(g).to receive(:reload)
          allow(g).to receive(:update!)
            .and_raise(ActiveRecord::RecordInvalid.new(g))
        end
      end

      it 'sets the :redirect_object to nil' do
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        result = described_class.update(group: group, params: p)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets an error message' do
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        result = described_class.update(group: group, params: p)
        expect(result[:msg]).to have_key(:error)
      end
    end
  end
  def expandable_group(size: 1)
    FactoryGirl.create(:full_group, size: size).tap do |g|
      g.draw.suites << FactoryGirl.create(:suite_with_rooms,
                                          rooms_count: size + 1)
    end
  end
end
