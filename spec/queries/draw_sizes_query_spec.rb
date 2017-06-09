# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawSizesQuery do
  it 'returns an array of all ungrouped suite and group sizes for a draw' do
    expected = [1, 2, 3, 5]
    create_groups([1, 1, 2, 3])
    create_suites([5])
    expect(described_class.call).to eq(expected)
  end

  it 'restricts group query to specific draw if passed' do
    draw = FactoryGirl.create(:draw)
    create_groups([1, 2], draw)
    create_groups([3])
    expect(described_class.call(draw: draw)).to eq([1, 2])
  end

  it 'restricts suite query to specific draw if passed' do
    draw = FactoryGirl.create(:draw)
    create_suites([1, 2], draw)
    create_suites([3])
    expect(described_class.call(draw: draw)).to eq([1, 2])
  end

  it 'sorts the resulting array' do
    create_groups([3, 1, 2])
    expect(described_class.call).to eq([1, 2, 3])
  end

  def create_groups(sizes, draw = nil)
    sizes.each do |size|
      group = FactoryGirl.create(:full_group, size: size)
      next unless draw
      group.members.each { |u| u.update(draw_id: draw.id) }
      # rubocop:disable Rails/SkipsModelValidations
      group.update_column(:draw_id, draw.id)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def create_suites(sizes, draw = nil)
    sizes.each do |size|
      suite = FactoryGirl.create(:suite_with_rooms, rooms_count: size)
      draw.suites << suite if draw
    end
  end
end
