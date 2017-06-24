# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawReport do
  describe '#sizes' do
    it 'returns a sorted list of suite sizes and group sizes' do
      suites = [1, 2, 3, 4]
      groups = [1, 3, 5]
      draw = instance_spy('draw', suite_sizes: suites, group_sizes: groups)
      expect(described_class.new(draw).sizes).to eq([1, 2, 3, 4, 5])
    end
  end

  describe '#groups' do
    it 'gets the groups with the leader eager-loaded' do
      groups = instance_spy('ActiveRecord::Associations::CollectionProxy')
      allow(groups).to receive(:includes).with(:leader).and_return(1)
      draw = instance_spy('draw', groups: groups)
      expect(described_class.new(draw).groups).to eq(1)
    end
  end

  describe '#group_counts' do
    it 'returns a hash of size => # of groups' do
      group = FactoryGirl.create(:open_group)
      draw = group.draw
      expect(described_class.new(draw).group_counts).to eq(group.size => 1)
    end
  end

  describe '#locked_counts' do
    it 'returns a hash of size => # of locked groups' do
      size = 2
      draw = FactoryGirl.create(:locked_group, size: size).draw
      FactoryGirl.create(:group, leader: FactoryGirl.create(:user, draw: draw),
                                 size: size)
      expect(described_class.new(draw).locked_counts).to eq(size => 1)
    end
  end

  describe '#oversubscription' do
    it 'returns a hash of size => difference between # groups & # suites' do
      draw = FactoryGirl.create(:oversubscribed_draw)
      size = draw.groups.first.size
      expect(described_class.new(draw).oversubscription).to eq(size => -1)
    end
  end

  describe '#suite_counts' do
    it 'returns the number of available suites grouped by size ' do
      size = 2
      draw = FactoryGirl.create(:full_group, :with_suite, size: size).draw
      FactoryGirl.create(:suite_with_rooms, rooms_count: size, draws: [draw])
      # 1 => 1 created during draw creation
      expect(described_class.new(draw).suite_counts).to eq(size => 1, 1 => 1)
    end
  end

  describe '#valid_suites' do
    it 'returns non-medical, available suites of the given size' do
      size = 2
      draw = FactoryGirl.create(:full_group, :with_suite, size: size).draw
      suite = valid_suite(draw: draw, size: size)
      expect(described_class.new(draw).valid_suites(size: size)).to \
        eq(suite.building => [suite])
    end

    # rubocop:disable RSpec/InstanceVariable
    def valid_suite(draw:, size:)
      return @suite if @suite
      FactoryGirl.create(:suite_with_rooms, draws: [draw], medical: true,
                                            rooms_count: size)
      FactoryGirl.create(:suite_with_rooms, draws: [draw],
                                            rooms_count: size + 1)
      @suite = FactoryGirl.create(:suite_with_rooms,
                                  rooms_count: size, draws: [draw])
    end
    # rubocop:enable RSpec/InstanceVariable
  end

  describe '#ungrouped_students' do
    it 'calls the ungrouped students query' do
      draw = FactoryGirl.create(:draw_with_members)
      allow(UngroupedStudentsQuery).to receive(:new).and_call_original
      described_class.new(draw).ungrouped_students
      expect(UngroupedStudentsQuery).to have_received(:new).with(draw.students)
    end
    it 'groups by intent and removes off campus' do
      draw = FactoryGirl.create(:draw_with_members)
      draw.students << FactoryGirl.create(:student, intent: 'off_campus')
      on_campus = draw.students.where(intent: 'on_campus')
      expect(described_class.new(draw).ungrouped_students).to \
        eq('on_campus' => on_campus)
    end
  end

  describe '#intent_metrics' do
    it 'calls the intent metrics query' do
      draw = instance_spy('draw')
      allow(IntentMetricsQuery).to receive(:call).with(draw).and_return('stub')
      expect(described_class.new(draw).intent_metrics).to eq('stub')
    end
  end
end
