# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessGroupCreator do
  let(:leader_draw_membership) do
    instance_spy('DrawMembership', user_id: 1, draw_id: 1, present?: true)
  end
  let(:other_member) do
    instance_spy('DrawMembership', user_id: 2, draw_id: 1, present?: true)
  end
  let(:params_hash) do
    { size: '2', leader: leader_draw_membership.user_id.to_s,
      member_ids: [other_member.user_id.to_s] }
  end
  let(:group) { instance_spy('Group') }

  before do
    allow(SuiteSizesQuery).to \
      receive(:call).and_return([params_hash[:size].to_i])

    allow(Group).to receive(:new).and_return(group)

    allow(DrawMembership).to receive(:where)
      .with(user_id: other_member.user_id.to_s, active: true)
      .and_return([other_member])

    allow(DrawMembership).to receive(:where)
      .with(user_id: leader_draw_membership.user_id.to_s, active: true)
      .and_return([leader_draw_membership])
  end

  context 'validation' do
    # note: params_hash is a hash containing a size,
    #   a leader_id, and an array containing a member_id
    it 'is not valid if no size is given' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash.merge(size: nil))
      expect(described_class.new(params: params)).not_to be_valid
    end

    it 'is not valid if the size given is not an existing suite size' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash.merge(size: 1))
      allow(SuiteSizesQuery).to receive(:call).and_return([50])
      expect(described_class.new(params: params)).not_to be_valid
    end

    it 'is valid if a size given is an existing suite size' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      allow(SuiteSizesQuery).to receive(:call)
        .and_return([params_hash[:size].to_i])
      expect(described_class.new(params: params)).to be_valid
    end
  end

  context 'draw membership handling' do
    let(:params) do
      params_hash.merge(member_ids: [other_member.user_id.to_s, '3'])
    end

    before do
      allow(DrawMembership).to receive(:where)
        .with(user_id: '3', active: true)
        .and_return([])
      allow(DrawMembership).to receive(:new)
        .with(user_id: '3', active: true)
        .and_return(instance_spy(DrawMembership, user_id: 3, present?: true))
    end

    it 'creates a draw membership if one does not exist' do
      described_class.new(params: params)
      expect(DrawMembership).to have_received(:new).with(user_id: '3',
                                                         active: true)
    end
  end

  context 'success' do
    it 'successfully creates a group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      # group is the stubbed return from `Group.new`
      expect(group).to have_received(:save!)
    end
    it 'gives group the correct params' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      hash = { size: '2', leader_draw_membership: leader_draw_membership,
               draw_memberships: [other_member, leader_draw_membership] }
      expect(Group).to have_received(:new).with(hash)
    end
    it 'calls #remove_draw on the leader' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      # leader_draw_membership is a stubbed draw_membership defined up top
      expect(leader_draw_membership).to have_received(:remove_draw)
    end
    it 'calls #remove_draw on all members' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      # other_member is a stubbed draw_membership defined up top
      expect(other_member).to have_received(:remove_draw)
    end
    it 'automatically sets the intents of members if necessary' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      expect(leader_draw_membership).to \
        have_received(:update!).with(intent: 'on_campus')
    end
    it 'returns the group object' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.create(params: params)[:record]).to eq(group)
    end
    it 'returns a success flash message' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.create(params: params)[:msg]).to have_key(:success)
    end
    it 'ignores the :remove_ids parameter' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash.merge('remove_ids' => ['1']))
      expect(described_class.create(params: params)[:redirect_object]).to \
        be_truthy
    end
  end

  context 'failure' do
    it 'does not create when given invalid params' do
      # since we have already stubbed out DrawMembership.where we
      #   need to stub out where queries with other parameters as well
      allow(DrawMembership).to receive(:where)
        .with(user_id: nil, active: true).and_return([])
      params = instance_spy('ActionController::Parameters', to_h: {})
      expect(described_class.create(params: params)[:redirect_object]).to be_nil
    end
    it 'returns the group object even if invalid' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      err = ActiveRecord::RecordInvalid.new(described_class.new(params: params))
      allow(group).to receive(:save!).and_raise(err)
      expect(described_class.create(params: params)[:record]).to eq(group)
    end
  end
end
