# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsReport do
  describe '#by_size' do
    it 'returns a hash of arrays sorted by status, grouped by size' do
      size = 2
      groups = groups_of_each_status(size: size)
      expected = { size => groups.sort_by { |g| Group.statuses[g.status] } }
      expect(described_class.new(groups).by_size).to eq(expected)
    end
    it 'sets the hash default to an empty array' do
      size = 2
      groups = groups_of_each_status(size: size)
      expect(described_class.new(groups).by_size[size + 1]).to eq([])
    end

    # rubocop:disable RSpec/InstanceVariable
    def groups_of_each_status(size:)
      return @groups if @groups
      draw = FactoryGirl.create(:draw_with_members, status: 'pre_lottery')
      group_in_draw(factory: :open_group, draw: draw, size: size)
      group_in_draw(factory: :full_group, draw: draw, size: size)
      group_in_draw(factory: :locked_group, draw: draw, size: size)
      @groups = draw.groups
    end
    # rubocop:enable RSpec/InstanceVariable
  end

  context 'assignment methods' do
    describe '#with_suites' do
      it 'returns all the groups with suites from the collection' do
        groups # initialize the data: one group with a suite, one without
        expect(described_class.new(groups).with_suites).to eq([groups.first])
      end
    end

    describe '#with_suites_count' do
      it 'returns the number of groups with suites assigned' do
        groups # initialize the data: one group with a suite, one without
        expect(described_class.new(groups).with_suites_count).to eq(1)
      end
    end

    describe '#without_rooms_count' do
      it 'returns the number of groups with suites assigned' do
        # initialize the data: one group with a suite, one without
        groups(with_count: 2, total_count: 3)
        assign_room(group: groups.first)
        expect(described_class.new(groups).without_rooms_count).to eq(1)
      end
    end

    describe '#without_suites' do
      it 'returns the groups without suites assigned' do
        groups # initialize the data: one group with a suite, one without
        expect(described_class.new(groups).without_suites).to eq([groups.last])
      end
    end

    describe '#without_suites_by_size' do
      it 'returns the groups without suites assigned grouped by size' do
        groups # initialize the data: one group with a suite, one without
        exp = { 1 => [groups.last] }
        expect(described_class.new(groups).without_suites_by_size).to eq(exp)
      end
    end

    describe '#without_suites_count' do
      it 'returns the number of groups without suites assigned' do
        groups # initialize the data: one group with a suite, one without
        expect(described_class.new(groups).without_suites_count).to eq(1)
      end
    end

    # rubocop:disable RSpec/InstanceVariable
    # Creates one group with a suite and one group without a suite
    def groups(with_count: 1, total_count: 2)
      return @groups if @groups
      draw = FactoryGirl.create(:draw_in_selection, groups_count: total_count)
      with_count.times do |i|
        group = draw.groups[i]
        suite = draw.available_suites.where(size: group.size).first
        group.update(suite: suite)
      end
      @groups = draw.groups
    end
    # rubocop:enable RSpec/InstanceVariable
  end

  def group_in_draw(factory:, draw:, size:, **attrs)
    FactoryGirl.create(factory, :defined_by_draw, draw: draw, size: size,
                                                  **attrs)
  end

  def assign_room(group:)
    group.leader.update(room: group.suite.rooms.first)
    group
  end
end
