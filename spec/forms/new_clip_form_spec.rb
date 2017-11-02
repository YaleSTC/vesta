# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewClipForm do
  # This will create a clip of length 2 by default or a clip of length 3
  # if the value '1' is passed into the `add_self` variable
  let(:draw) { FactoryGirl.create(:draw) }
  let(:groups) { FactoryGirl.create_pair(:group_from_draw, draw: draw) }
  let(:group_ids) { groups.map(&:id).map(&:to_s) }
  let(:group) { create(:group_from_draw, draw: draw) }

  # Each shared 'success' example must define the following params in let blocks
  # user [User] a user with the role being tested
  # add_self [String] if the user is a housing rep set it to '1' to add
  #   them to the clip, '0' to make the clip without them. Set this to nil if
  #   the user is not a housing rep.
  # size [Integer] the expected size of the created clip
  # mail_count [Integer] the expected amount of email invites sent out
  shared_examples 'success' do
    let(:param_hash) do
      { draw_id: draw.id.to_s, group_ids: group_ids,
        add_self: add_self }
    end
    let(:p) { instance_spy('ActionController::Parameters', to_h: param_hash) }

    it 'creates a clip and sets the redirect object correctly' do
      r = described_class.new(admin: user.admin?, params: p).submit
      expect(r[:redirect_object]).to be_instance_of(Clip)
    end
    it 'creates a clip of correct size' do
      r = described_class.new(admin: user.admin?, params: p).submit
      clip = r[:redirect_object]
      expect(clip.clip_memberships.length).to eq(size)
    end
    it 'returns a success flash message' do
      r = described_class.new(admin: user.admin?, params: p).submit
      expect(r[:msg]).to have_key(:success)
    end
    it 'sets :form_object to nil' do
      r = described_class.new(admin: user.admin?, params: p).submit
      expect(r[:form_object]).to eq(nil)
    end
  end

  # Each shared 'failure' example must define the following params in let blocks
  # user [User] a user with the role being tested
  # add_self [Boolean] if the user is a housing rep set it to true to add
  #   them to the clip, false to make the clip without them. Set this to nil if
  #   the user is not a housing rep.
  # invalid_groups [Array<String>] group ids in an array that are too few in
  #   number to pass the size validations in the creator (can be nil or
  #   empty strings)

  shared_examples 'failure' do
    context 'when no draw has been given' do
      it 'sets the redirect object to nil' do
        param_hash = { draw_id: '', group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(admin: user.admin?, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        param_hash = { draw_id: '', group_ids: group_ids }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(admin: user.admin?, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end

    context 'when too few groups are passed' do
      it 'sets the redirect object to nil' do
        param_hash = { draw_id: draw.id.to_s, group_ids: invalid_groups }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(admin: user.admin?, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        param_hash = { draw_id: draw.id.to_s, group_ids: invalid_groups }
        p = instance_spy('ActionController::Parameters', to_h: param_hash)
        r = described_class.new(admin: user.admin?, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end

    context 'invalid params are passed' do
      it 'sets the redirect object to nil' do
        p = instance_spy('ActionController::Parameters', to_h: {})
        r = described_class.new(admin: user.admin?, params: p).submit
        expect(r[:redirect_object]).to be_nil
      end
      it 'returns the form object' do
        p = instance_spy('ActionController::Parameters', to_h: {})
        r = described_class.new(admin: user.admin?, params: p).submit
        expect(r[:form_object]).to be_instance_of(described_class)
      end
    end
  end

  describe 'admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'success' do
      let(:size) { 2 }
      let(:add_self) { nil }
    end

    it_behaves_like 'failure' do
      let(:invalid_groups) { [group_ids.first] }
    end
  end

  describe 'housing_rep' do
    let(:user) { group.leader.tap { |u| u.update(role: 'rep') } }

    context 'including themselves in the group' do
      let(:group_ids) { groups.map(&:id).map(&:to_s) + [group.id.to_s] }

      it_behaves_like 'success' do
        let(:size) { 3 }
        let(:add_self) { '1' }
      end
    end

    context 'without including themselves in the group' do
      it_behaves_like 'success' do
        let(:size) { 2 }
        let(:add_self) { '0' }
      end
    end

    it_behaves_like 'failure' do
      let(:invalid_groups) { [group_ids.first] }
    end
  end

  describe 'leader' do
    let(:user) { group.leader.tap { |u| u.update(role: 'student') } }
    let(:group_ids) { groups.map(&:id).map(&:to_s) + [group.id.to_s] }

    it_behaves_like 'success' do
      let(:size) { 3 }
      let(:add_self) { '1' }
    end

    it_behaves_like 'failure' do
      let(:invalid_groups) { [''] }
    end
  end
end
