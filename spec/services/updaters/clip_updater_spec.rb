# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipUpdater do
  let(:clip) { create(:clip, groups_count: 3) }
  let(:group_ids) { clip.clip_memberships.map(&:group_id).map(&:to_s) }

  context 'action prevented' do
    let(:msg) { 'The draw of a clip cannot be changed' }

    it 'if it changes draw_id' do
      params = { draw_id: clip.draw_id + 1 }
      result = described_class.update(clip: clip, params: params)
      expect(result[:msg][:error]).to include(msg)
    end

    it 'if it changes draw' do
      new_draw = instance_spy('Draw')
      params = { draw: new_draw }
      result = described_class.update(clip: clip, params: params)
      expect(result[:msg][:error]).to include(msg)
    end

    it 'allows matching draw_id' do
      params = { draw_id: clip.draw.id }
      result = described_class.update(clip: clip, params: params)
      expect(result[:msg][:error]).not_to include(msg)
    end
  end

  context 'successfully' do
    context 'when adding a group' do
      let(:new_group) { create(:group_from_draw, draw: clip.draw) }
      let(:params) { { group_ids: group_ids << new_group.id.to_s } }

      it 'adds a member to the clip' do
        allow(ClipMembership).to receive(:create!).and_return(true)
        described_class.update(clip: clip, params: params_for_hash(params))
        expect(ClipMembership).to have_received(:create!).once
      end
    end

    context 'when removing a group' do
      let(:params) { { group_ids: group_ids.take(2) } }

      it 'removes the member from clip' do
        p = params_for_hash(params)
        expect { described_class.update(clip: clip, params: p) }.to \
          change { ClipMembership.count }.by(-1)
      end
    end

    context 'unconfirmed memberships cleanup' do
      let(:params) { { group_ids: group_ids } }

      it 'confirms previously unconfirmed memberships' do
        clip.clip_memberships.last.update(confirmed: false)
        p = params_for_hash(params)
        expect { described_class.update(clip: clip, params: p) }. to \
          change { ClipMembership.where(confirmed: true).count }.by(1)
      end
    end
  end

  context 'failure' do
    it "if there aren't enough groups" do
      params = { group_ids: ['1'] }
      result = described_class.update(clip: clip,
                                      params: params_for_hash(params))
      expect(result[:redirect_object]).to be_nil
    end

    it 'if there are invalid params' do
      result = described_class.update(clip: clip, params: params_for_hash({}))
      expect(result[:redirect_object]).to be_nil
    end
  end

  def params_for_hash(params)
    instance_spy('ActionController::Parameters', to_h: params)
  end
end
