# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsForClippingQuery do
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
