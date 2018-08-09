# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessGroupUpdater do
  describe '.update' do
    xit 'allows for calling :update on the parent class' do
    end
  end

  context 'size validations' do
    it 'fails if it is not an existing suite size' do
      group = create(:drawless_group, size: 2)
      p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
      allow(SuiteSizesQuery).to receive(:call).and_return([2])
      expect(described_class.update(group: group, params: p)[:msg]).to \
        have_key(:error)
    end
    it 'succeeds when it is an existing suite size' do
      group = create(:drawless_group, size: 2)
      p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
      allow(SuiteSizesQuery).to receive(:call).and_return([4])
      expect(described_class.update(group: group, params: p)[:msg]).to \
        have_key(:success)
    end
  end

  describe '#update' do
    # rubocop:disable RSpec/ExampleLength
    context 'group is full' do
      it 'deletes memberships for users being removed before updating' do
        group = create(:drawless_group, size: 2)
        to_remove = create(:membership, group: group).user
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'remove_ids' => [to_remove.id.to_s] })
        expect { described_class.update(group: group, params: p) }.to \
          change(Membership, :count).by(-1)
      end
    end

    context 'users being added' do
      it 'moves the draw_id attribute to old_draw_id' do
        group = create(:drawless_group, size: 2)
        draw = create(:draw)
        to_add = create(:student_in_draw, draw: draw)
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'member_ids' => [to_add.id.to_s] })
        described_class.update(group: group, params: p)
        expect(to_add.draw_membership.reload.old_draw_id).to eq(draw.id)
      end
      it 'updates their intent to on_campus if necessary' do
        group = create(:drawless_group, size: 2)
        to_add = create(:student_in_draw, intent: 'undeclared')
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'member_ids' => [to_add.id.to_s] })
        described_class.update(group: group, params: p)
        expect(to_add.draw_membership.reload.intent).to eq('on_campus')
      end
    end

    context 'users being removed' do
      it 'moves the old_draw_id attribute to draw_id' do
        group = create(:drawless_group, size: 2)
        draw = create(:draw)
        to_remove = create(:student)
        create(:draw_membership, user: to_remove, draw: nil,
                                 old_draw_id: draw.id)
        create(:membership, user: to_remove, group: group)
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'remove_ids' => [to_remove.id.to_s] })
        described_class.update(group: group, params: p)
        expect(to_remove.draw_membership.reload.draw_id).to eq(draw.id)
      end
      it 'does not remove the leader if passed' do
        group = create(:drawless_group, size: 2)
        p = instance_spy('ActionController::Parameters',
                         to_h: { 'remove_ids' => [group.leader.id.to_s] })
        expect { described_class.update(group: group, params: p) }.not_to \
          change(Membership, :count)
      end
    end

    context 'success' do
      it 'sets to the :redirect_object to the group' do
        group = instance_spy('group', update!: true)
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        allow(SuiteSizesQuery).to receive(:call).and_return([group.size, 4])
        result = described_class.update(group: group, params: p)
        expect(result[:redirect_object]).to eq(group)
      end
      it 'sets the :group to the group' do
        group = instance_spy('group', update!: true)
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        allow(SuiteSizesQuery).to receive(:call).and_return([group.size, 4])
        result = described_class.update(group: group, params: p)
        expect(result[:record]).to eq(group)
      end
      it 'sets a success message' do
        group = instance_spy('group', update!: true)
        p = instance_spy('ActionController::Parameters', to_h: { size: 4 })
        allow(SuiteSizesQuery).to receive(:call).and_return([group.size, 4])
        result = described_class.update(group: group, params: p)
        expect(result[:msg]).to have_key(:success)
      end
    end
  end
end
