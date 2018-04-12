# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawReport do
  describe '#refresh' do
    it 'recreates the report object' do
      draw = instance_spy('draw')
      report = described_class.new(draw)
      allow(described_class).to receive(:new).with(draw).and_return('stub')
      expect(report.refresh).to eq('stub')
    end
  end
  describe '#sizes' do
    it 'returns a sorted list of suite sizes and group sizes' do
      suites = [1, 2, 3, 4]
      groups = [1, 3, 5]
      draw = instance_spy('draw', suite_sizes: suites, group_sizes: groups)
      expect(described_class.new(draw).sizes).to eq([1, 2, 3, 4, 5])
    end
  end

  describe '#groups' do
    it 'gets the groups with the a bunch of stuff eager-loaded' do
      groups = instance_spy('ActiveRecord::Associations::CollectionProxy')
      eager_loads = [:leader, :lottery_assignment, suite: :building]
      allow(groups).to receive(:includes).with(*eager_loads).and_return(1)
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

  describe '#oversubscribed_sizes' do
    it 'returns an array of over subscribed sizes' do
      draw = FactoryGirl.create(:oversubscribed_draw)
      size = draw.groups.first.size
      expect(described_class.new(draw).oversubscribed_sizes).to eq([size])
    end
  end

  describe '#oversubscribed?' do
    it 'returns true when > 0 oversubscribed sizes' do
      draw = FactoryGirl.create(:oversubscribed_draw)
      expect(described_class.new(draw).oversubscribed?).to be(true)
    end
    it 'returns false when no oversubscribed sizes' do
      draw = FactoryGirl.create(:draw)
      expect(described_class.new(draw).oversubscribed?).to be(false)
    end
  end

  describe '#suite_counts' do
    it 'returns the number of available suites grouped by size ' do
      size = 2
      draw = FactoryGirl.create(:group_with_suite, size: size).draw
      FactoryGirl.create(:suite_with_rooms, rooms_count: size, draws: [draw])
      # 1 => 1 created during draw creation
      expect(described_class.new(draw).suite_counts).to eq(size => 1, 1 => 1)
    end
  end

  describe '#valid_suites' do
    it 'excludes non-valid suites' do # rubocop:disable RSpec/ExampleLength
      size = 2
      draw = FactoryGirl.create(:group_with_suite, size: size).draw
      create_invalid_suites(draw: draw, size: size)
      valid_suite = FactoryGirl.create(:suite_with_rooms, rooms_count: size,
                                                          draws: [draw])
      expect(described_class.new(draw).valid_suites(size: size)).to \
        eq(valid_suite.building => [valid_suite])
    end

    def create_invalid_suites(draw:, size:)
      FactoryGirl.create(:suite_with_rooms, draws: [draw], medical: true,
                                            rooms_count: size)
      FactoryGirl.create(:suite_with_rooms, draws: [draw],
                                            rooms_count: size + 1)
      FactoryGirl.create(:suite_with_rooms, rooms_count: size)
    end
  end

  describe '#suites_by_size' do
    it 'groups available suites by size' do
      suites = [instance_spy('suite')]
      qo = instance_spy(SuitesBySizeQuery, call: {})
      allow(SuitesBySizeQuery).to receive(:new).with(suites).and_return(qo)
      draw = instance_spy('draw', available_suites: suites)
      expect(described_class.new(draw).suites_by_size).to eq({})
    end
  end

  describe '#ungrouped_students_by_intent' do
    it 'calls the ungrouped students query' do
      draw = FactoryGirl.create(:draw_with_members)
      allow(UngroupedStudentsQuery).to receive(:new).and_call_original
      described_class.new(draw).ungrouped_students_by_intent
      expect(UngroupedStudentsQuery).to have_received(:new).with(draw.students)
    end
    it 'groups by intent and removes off campus' do
      draw = FactoryGirl.create(:draw_with_members)
      draw.students << FactoryGirl.create(:student, intent: 'off_campus')
      on_campus = draw.students.where(intent: 'on_campus')
      expect(described_class.new(draw).ungrouped_students_by_intent).to \
        eq('on_campus' => on_campus)
    end
  end

  describe '#intent_metrics' do
    it 'calls the intent metrics query' do
      draw = instance_spy('draw')
      allow(IntentMetricsQuery).to receive(:call).with(draw).and_return('stub')
      expect(described_class.new(draw).intent_metrics).to eq('stub')
    end

    it 'returns a count of each intent' do
      draw = FactoryGirl.create(:draw)
      draw.students << FactoryGirl.create(:student, intent: 'on_campus')
      draw.students << FactoryGirl.create(:student, intent: 'off_campus')
      draw.students << FactoryGirl.create(:student, intent: 'undeclared')
      expect(described_class.new(draw).intent_metrics.values).to eq([1, 1, 1])
    end
  end
end
