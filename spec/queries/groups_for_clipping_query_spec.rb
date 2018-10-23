# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsForClippingQuery do
  context 'when clipping group size is not restricted' do
    it 'returns groups without confirmed clip memberships' do
      group = create(:group)
      unconfirmed_groups = prepare_data(group)
      result = described_class.call(draw: group.draw, group: group)
      expect(result).to match_array(unconfirmed_groups)
    end

    it 'restricts the result to the passed query' do
      clip = create(:clip)
      clip.clip_memberships.each { |m| m.update(confirmed: false) }
      query = Group.where.not(id: clip.groups.last.id)
      result = described_class.new(query).call(draw: clip.draw)
      expect(result).to eq([clip.groups.first])
    end

    it 'raises an error if no draw is provided' do
      expect { described_class.call } .to raise_error(ArgumentError)
    end

    def prepare_data(group)
      # This creates a group outside the draw and groups with confirmed
      # clip memberships that won't be returned by the query
      create(:group)
      clip = create(:clip, draw: group.draw)
      # This creates the types of groups that will be returned by the query
      create_pair(:group_from_draw, draw: group.draw).tap do |groups|
        create(:clip_membership, clip: clip, group: groups.last,
                                 confirmed: false)
      end
    end
  end

  context 'when clipping group size is restricted' do
    it 'returns groups of the same size' do
      draw, quad1, quad2, quad3 = setup
      result = described_class.call(draw: draw, group: quad3)
      expect(result).to match_array([quad1, quad2])
    end

    context 'when no group is given' do
      it 'returns all groups' do
        draw, quad1, quad2, quad3, single = setup
        result = described_class.call(draw: draw, group: nil)
        expect(result).to match_array([quad1, quad2, quad3, single])
      end
    end

    def setup
      draw = create(:draw, restrict_clipping_group_size: true,
                           status: 'group_formation')
      quad1 = create(:locked_group, :defined_by_draw, draw: draw, size: 4)
      quad2 = create(:locked_group, :defined_by_draw, draw: draw, size: 4)
      quad3 = create(:locked_group, :defined_by_draw, draw: draw, size: 4)
      single = create(:locked_group, :defined_by_draw, draw: draw, size: 1)

      [draw, quad1, quad2, quad3, single]
    end
  end
end
