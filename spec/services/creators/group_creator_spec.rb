# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupCreator do
  let(:draw) { instance_spy('Draw', open_suite_sizes: [2], id: 1) }
  let(:leader_draw_membership) do
    instance_spy('DrawMembership', user_id: 1, draw_id: 1)
  end
  let(:other_member) do
    instance_spy('DrawMembership', user_id: 2, draw_id: 1)
  end
  let(:params_hash) do
    { size: '2', leader: leader_draw_membership.user_id.to_s,
      member_ids: [other_member.user_id.to_s] }
  end
  let(:group) { instance_spy('Group') }

  before do
    allow(Group).to receive(:new).and_return(group)

    allow(DrawMembership).to receive(:where)
      .with(user_id: other_member.user_id.to_s, active: true)
      .and_return([other_member])

    allow(DrawMembership).to receive(:where)
      .with(user_id: leader_draw_membership.user_id.to_s, active: true)
      .and_return([leader_draw_membership])

    allow(Draw).to receive(:find).with(draw.id).and_return(draw)
  end

  context 'size validations' do
    # note: params_hash is a hash containing a size,
    #   a leader_id, and an array containing a member_id
    it 'fails if it is not an existing suite size' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash.merge(size: '1'))
      allow(draw).to receive(:open_suite_sizes).and_return([50])
      expect(described_class.new(params: params)).not_to be_valid
    end
    it 'succeeds when it is an existing suite size' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      allow(draw).to receive(:open_suite_sizes)
        .and_return([params_hash[:size].to_i])
      expect(described_class.new(params: params)).to be_valid
    end
  end

  context 'draw validations' do
    # rubocop:disable RSpec/ExampleLength
    it 'fail if the users are in different draws' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      wrong_draw_member = instance_spy('DrawMembership', user_id: 2, draw_id: 2)
      # this stubs out the call to allow for the drawmembership with the wrong
      #   draw number to be found
      allow(DrawMembership).to \
        receive(:where)
        .with(user_id: wrong_draw_member.user_id.to_s, active: true)
        .and_return([wrong_draw_member])
      expect(described_class.new(params: params)).not_to be_valid
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context 'success' do
    it 'successfully creates a group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      # group is the stubbed return from `Group.new`
      expect(group).to have_received(:save!)
    end
    it 'gives group the correct params' do # rubocop:disable RSpec/ExampleLength
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      described_class.create(params: params)
      hash = { size: '2', leader_draw_membership: leader_draw_membership,
               draw_memberships: [other_member, leader_draw_membership],
               draw: draw }
      expect(Group).to have_received(:new).with(hash)
    end
    it 'returns the group object' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.create(params: params)[:group]).to eq(group)
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
      params = instance_spy('ActionController::Parameters', to_h: {})
      # since we have already stubbed out DrawMembership.where and Draw.where we
      #   need to stub out where queries with other parameters as well
      allow(DrawMembership).to receive(:where)
        .with(user_id: nil, active: true).and_return([])
      allow(Draw).to receive(:find).with(nil).and_return(nil)
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
