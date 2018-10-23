# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewClipForm do
  # This will create a clip of length 2 by default
  let(:draw) do
    create(:draw, allow_clipping: true, restrict_clipping_group_size: false)
  end
  let(:groups) { create_pair(:group_from_draw, draw: draw) }
  let(:group_ids) { groups.map(&:id).map(&:to_s) }
  let(:group) { create(:group_from_draw, draw: draw) }
  let(:clip) { create(:clip) }

  # Each shared 'success' example must define the following params in let blocks
  # user [User] a user with the role being tested
  # size [Integer] the expected size of the created clip
  # mail_count [Integer] the expected amount of email invites sent out
  shared_examples 'success' do
    let(:param_hash) do
      { draw_id: draw.id.to_s, group_ids: group_ids }
    end
    let(:p) { instance_spy('ActionController::Parameters', to_h: param_hash) }

    it 'creates a clip and sets the redirect object correctly' do
      r = described_class.new(role: user.role, params: p).submit
      expect(r[:redirect_object]).to be_instance_of(Clip)
    end
    it 'creates a clip of correct size' do
      r = described_class.new(role: user.role, params: p).submit
      clip = r[:redirect_object]
      expect(clip.clip_memberships.length).to eq(size)
    end
    it 'returns a success flash message' do
      r = described_class.new(role: user.role, params: p).submit
      expect(r[:msg]).to have_key(:success)
    end
    it 'sets :form_object to nil' do
      r = described_class.new(role: user.role, params: p).submit
      expect(r[:form_object]).to eq(nil)
    end
  end

  # Each shared 'failure' example must define the following params in let blocks
  # user [User] a user with the role being tested
  # invalid_groups [Array<String>] group ids in an array that are too few in
  #   number to pass the size validations in the creator (can be nil or
  #   empty strings)

  shared_examples 'failure' do
    context 'when no draw has been given' do
      it 'sets the redirect object to nil' do
        param_hash = { draw_id: '', group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        param_hash = { draw_id: '', group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end

    context 'when too few groups are passed' do
      it 'sets the redirect object to nil' do
        param_hash = { draw_id: draw.id.to_s, group_ids: invalid_groups }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        param_hash = { draw_id: draw.id.to_s, group_ids: invalid_groups }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end

    context 'invalid params are passed' do
      it 'sets the redirect object to nil' do
        p = instance_spy('ActionController::Parameters', to_h: {})
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        p = instance_spy('ActionController::Parameters', to_h: {})
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end

    context 'when draw clipping disallowed' do
      let(:clipless_draw) { create(:draw, allow_clipping: false) }

      it 'sets the redirect object to nil' do
        param_hash = { draw_id: clipless_draw.id.to_s, group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        param_hash = { draw_id: clipless_draw.id.to_s, group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
      it 'returns the correct error message' do
        param_hash = { draw_id: clipless_draw.id.to_s, group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        msg = 'This draw currently does not allow for clipping.'
        expect(r[:msg][:error]).to include(msg)
      end
    end

    context 'group is already in a clip' do
      it 'sets the redirect object to nil' do
        param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        groups.first.clip = clip
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        groups.first.clip = clip
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end

    context 'group draw and clip draw do not match' do
      it 'checks matching draw validation' do
        new_draw = create(:draw)
        param_hash = { draw_id: new_draw.id.to_s, group_ids: [[group.id]] }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        new_draw = create(:draw)
        param_hash = { draw_id: new_draw.id.to_s, group_ids: [[group.id]] }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(role: user.role, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end
  end

  shared_examples 'clipping restricted' do
    it 'sets the redirect object to nil' do
      params = restricted_draw_setup
      r = described_class.new(role: user.role, params: params).submit
      expect(r[:redirect_object]).to be_nil
    end

    it 'returns the form object' do
      params = restricted_draw_setup
      r = described_class.new(role: user.role, params: params).submit
      expect(r[:form_object]).to be_instance_of(described_class)
    end

    def restricted_draw_setup
      restricted_draw = create(:draw, status: 'group_formation',
                                      restrict_clipping_group_size: true)
      quad = create(:locked_group, :defined_by_draw,
                    draw: restricted_draw, size: '4')
      trip = create(:locked_group, :defined_by_draw,
                    draw: restricted_draw, size: '1')
      { draw_id: restricted_draw.id.to_s,
        group_ids: [quad.id.to_s, trip.id.to_s] }
    end
  end

  describe 'admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'success' do
      let(:size) { 2 }
    end

    it_behaves_like 'failure' do
      let(:invalid_groups) { [group_ids.first] }
    end

    it_behaves_like 'clipping restricted'

    it 'creates a fully confirmed clip' do
      param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
      p = instance_spy('ActionController::Parameters', to_h: param_hash)
      described_class.new(role: user.role, params: p).submit
      expect(ClipMembership.all.map(&:confirmed)).to match_array([true, true])
    end
  end

  describe 'housing_rep' do
    let(:user) { group.leader.tap { |u| u.update(role: 'rep') } }

    context 'including themselves in the group' do
      let(:group_ids) { groups.map(&:id).map(&:to_s) + [group.id.to_s] }

      it_behaves_like 'success' do
        let(:size) { 3 }
      end
    end

    context 'without including themselves in the group' do
      it_behaves_like 'success' do
        let(:size) { 2 }
      end
    end

    it_behaves_like 'failure' do
      let(:invalid_groups) { [group_ids.first] }
    end

    it_behaves_like 'clipping restricted'

    it "doesn't automatically includes the rep's group in the clip" do
      param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
      p = instance_spy('ActionController::Parameters', to_h: param_hash)
      described_class.new(role: user.role, params: p).submit
      expect(ClipMembership.all.count).to eq(2)
    end

    it 'creates a fully unconfirmed clip' do
      param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
      p = instance_spy('ActionController::Parameters', to_h: param_hash)
      described_class.new(role: user.role, params: p).submit
      expect(ClipMembership.all.map(&:confirmed)).to match_array([false, false])
    end
  end

  describe 'leader' do
    let(:user) { group.leader.tap { |u| u.update(role: 'student') } }
    let(:group_ids) { groups.map(&:id).map(&:to_s) + [group.id.to_s] }

    it_behaves_like 'success' do
      let(:size) { 3 }
    end

    it_behaves_like 'failure' do
      let(:invalid_groups) { [''] }
    end

    it 'automatically includes the user\'s group in the clip membership' do
      param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
      p = instance_spy('ActionController::Parameters', to_h: param_hash)
      described_class.new(role: user.role, params: p).submit
      expect(ClipMembership.all.count).to eq(3)
    end

    it 'creates a partially confirmed clip' do
      param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
      p = instance_spy('ActionController::Parameters', to_h: param_hash)
      described_class.new(role: user.role, params: p).submit
      expect(ClipMembership.all.map(&:confirmed))
        .to match_array([true, false, false])
    end

    it 'only confirms their group\'s membership in the clip' do
      param_hash = { draw_id: draw.id.to_s, group_ids: group_ids }
      p = instance_spy('ActionController::Parameters', to_h: param_hash)
      described_class.new(role: user.role, params: p).submit
      expect(user.group.clip_membership.confirmed).to be(true)
    end
  end
end
