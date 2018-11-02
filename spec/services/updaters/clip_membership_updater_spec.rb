# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembershipUpdater do
  let(:draw) { instance_spy('Draw', group_formation?: true) }
  let(:clip) { instance_spy('Clip', draw: draw, name: 'Test') }
  let(:group) { instance_spy('Group', name: 'Name', draw: draw) }
  let(:membership) do
    instance_spy('ClipMembership', clip: clip, confirmed: false, group: group)
  end

  describe 'freezes clip before update' do
    let(:msg) { 'Clip cannot be changed' }

    it 'cannot change clip' do
      new_clip = instance_spy('Clip')
      new_params = { clip: new_clip }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end

    it 'cannot change clip id' do
      allow(membership).to receive(:clip_id).and_return(1)
      new_params = { clip_id: 2 }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end

    it 'cannot join nil clip' do
      allow(membership).to receive(:clip_id).and_return(1)
      new_params = { clip_id: nil }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end
  end

  describe 'freezes group before update' do
    let(:msg) { 'Group cannot be changed' }

    it 'cannot change group' do
      new_group = instance_spy('Group')
      new_params = { group: new_group }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end
    it 'cannot change group id' do
      allow(membership).to receive(:group_id).and_return(1)
      new_params = { group_id: 2 }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end
    it 'cannot join nil group' do
      allow(membership).to receive(:group_id).and_return(1)
      new_params = { group_id: nil }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end
  end

  describe 'freezes confirm unless group-formation' do
    let(:msg) { 'Draw must be in group formation phase.' }

    it 'cannot change confirmation if not group-formation' do
      allow(draw).to receive(:group_formation?).and_return(false)
      new_params = { confirmed: true }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:error]).to include(msg)
    end

    it 'can change confirmation if group-formation' do
      allow(draw).to receive(:group_formation?).and_return(true)
      new_params = { confirmed: true }
      result = described_class.update(clip_membership: membership,
                                      params: new_params)
      expect(result[:msg][:success]).to eq("#{group.name} joined #{clip.name}.")
    end
  end

  context 'updating clip membership and returning correct values' do
    let(:params) { { confirmed: true } }

    it 'successfully updates a clip membership' do
      described_class.update(clip_membership: membership, params: params)
      expect(membership).to have_received(:update!)
    end

    it 'returns an array with the draw and the clip from the membership' do
      updater = described_class.new(clip_membership: membership, params: params)
      expect(updater.update[:redirect_object]).to eq([group.draw, group])
    end

    it 'returns the correct success message' do
      updater = described_class.new(clip_membership: membership, params: params)
      expect(updater.update[:msg][:success]).to \
        eq("#{group.name} joined #{clip.name}.")
    end
  end
end
