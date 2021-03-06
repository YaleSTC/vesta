# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Draw, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:draw_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:students).through(:draw_memberships) }
    it { is_expected.to have_many(:groups).dependent(:destroy) }
    it { is_expected.to have_many(:draw_suites).dependent(:delete_all) }
    it { is_expected.to have_many(:lottery_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:clips).dependent(:destroy) }
    it { is_expected.to have_many(:suites).through(:draw_suites) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:suite_selection_mode) }

    it 'cannot set intent deadline in the past' do
      draw = build(:draw, intent_deadline: Time.zone.today - 1)
      expect(draw).not_to be_valid
    end
    it 'cannot set locking deadline in the past' do
      draw = build(:draw, locking_deadline: Time.zone.today - 1)
      expect(draw).not_to be_valid
    end
    it 'cannot lock intent if undeclared students' do
      draw = create(:draw, status: 'group_formation')
      draw.students << create(:student, intent: 'undeclared')
      draw.intent_locked = true
      expect(draw).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'nullifies the draw_id field on users in the draw after destroy' do
      draw = create(:draw_with_members)
      students = draw.students
      draw.destroy
      expect(students.map(&:reload).map(&:draw_id).all?(&:nil?)).to be_truthy
    end
    it 'clears old_draw_id when necessary' do
      draw = create(:draw)
      dm = create(:draw_membership, draw: nil, old_draw_id: draw.id)
      draw.destroy
      expect(dm.reload.old_draw_id).to be_nil
    end
  end

  describe 'scoping students based on active status of the draw_memberships' do
    context 'with an inactive draw' do
      it 'will only be associated with draw_memberships that are inactive' do
        draw = create(:draw, active: false)
        create(:student_in_draw, draw: draw)
        s2 = create(:student_in_draw, draw: draw)
        s2.draw_memberships.first.update!(active: false)
        expect(draw.reload.students).to eq([s2])
      end
    end

    context 'with an active draw' do
      it 'will only be associated with draw_memberships that are active' do
        draw = create(:draw, active: true)
        s1 = create(:student_in_draw, draw: draw)
        s2 = create(:student_in_draw, draw: draw)
        s2.draw_membership.update!(active: false)
        expect(draw.students).to eq([s1])
      end
    end
  end

  describe '.active' do
    it 'scopes to active draws' do
      active, to_skip = create_pair(:draw, active: true)
      create(:draw, active: false)
      expect(described_class.where.not(id: to_skip.id).active).to \
        match_array([active])
    end
  end

  describe '#suite_sizes' do
    let(:draw) { build_stubbed(:draw) }

    it 'returns an array of all the available suite sizes in the draw' do
      instance_spy('SuiteSizesQuery', call: [1, 2]).tap do |q|
        allow(SuiteSizesQuery).to receive(:new).with(draw.suites.available)
                                               .and_return(q)
      end
      expect(draw.suite_sizes).to match_array([1, 2])
    end
  end

  describe '#group_sizes' do
    let(:draw) { build_stubbed(:draw) }

    it 'returns an array of group sizes in the draw' do
      instance_spy('group_sizes_query', call: [1, 2]).tap do |q|
        allow(GroupSizesQuery).to receive(:new).with(draw.suites.available)
                                               .and_return(q)
      end
      expect(draw.group_sizes).to match_array([1, 2])
    end
  end

  # this is testing a private method, feel free to remove it if it ever fails
  describe '#student_count' do
    it 'returns the number of students in the draw' do
      students = Array.new(3) { instance_spy('User') }
      draw = build_stubbed(:draw)
      allow(draw).to receive(:students).and_return(students)
      expect(draw.send(:student_count)).to eq(3)
    end
  end

  describe '#students?' do
    it 'returns true if the student_count is greater than zero' do
      draw = build_stubbed(:draw)
      allow(draw).to receive(:student_count).and_return(1)
      expect(draw.students?).to be_truthy
    end

    it 'returns false if the student_count is zero' do
      draw = build_stubbed(:draw)
      allow(draw).to receive(:student_count).and_return(0)
      expect(draw.students?).to be_falsey
    end
  end

  describe '#groups?' do
    it 'returns true if the group_count is greater than zero' do
      draw = build_stubbed(:draw)
      allow(draw).to receive(:group_count).and_return(1)
      expect(draw.groups?).to be_truthy
    end

    it 'returns false if the group_count is zero' do
      draw = build_stubbed(:draw)
      allow(draw).to receive(:group_count).and_return(0)
      expect(draw.groups?).to be_falsey
    end
  end

  describe '#enough_beds?' do
    it 'returns true if bed_count >= on_campus_student_count' do
      draw = build_stubbed(:draw)
      allow(draw).to receive(:bed_count).and_return(2)
      allow(draw).to receive(:on_campus_student_count).and_return(1)
      expect(draw.enough_beds?).to be_truthy
    end

    it 'returns false if bed_count < on_campus_student_count' do
      draw = build_stubbed(:draw)
      allow(draw).to receive(:bed_count).and_return(1)
      allow(draw).to receive(:on_campus_student_count).and_return(2)
      expect(draw.enough_beds?).to be_falsey
    end
  end

  describe '#open_suite_sizes' do
    it 'returns suite sizes in the draw minus locked sizes' do
      draw = build_stubbed(:draw, restricted_sizes: [1])
      all_sizes = [1, 2]
      allow(draw).to receive(:suite_sizes).and_return(all_sizes)
      expect(draw.open_suite_sizes).to eq([2])
    end
  end

  describe '#bed_count' do
    it 'returns the number of beds across all available suites' do
      draw = create(:draw_with_members, suites_count: 2)
      group = create(:locked_group, :defined_by_draw, draw: draw)
      draw.reload.suites.last.update(group: group)
      available_beds = draw.suites.sum(&:size) - draw.suites.last.size
      expect(draw.send(:bed_count)).to eq(available_beds)
    end
  end

  describe '#available_suites' do
    it 'returns suites without associated groups' do
      available = create(:suite)
      taken = create(:group_with_suite).suite_assignment.suite
      draw = create(:draw, suites: [available, taken])
      expect(draw.available_suites).to eq([available])
    end
  end

  describe '#all_students_grouped?' do
    it 'returns false if there are students in the draw not in a group' do
      draw = create(:draw_with_members, students_count: 2)
      create(:group, leader: draw.students.first)
      expect(draw.all_students_grouped?).to be_falsey
    end
    it 'checks undeclared students' do
      draw = create(:draw_with_members, students_count: 2)
      create(:group, leader: draw.students.first)
      draw.draw_memberships.last.update(intent: 'undeclared')
      expect(draw.all_students_grouped?).to be_falsey
    end
    it 'ignores off_campus students' do
      draw = create(:draw_with_members, students_count: 2)
      create(:group, leader: draw.students.first)
      draw.draw_memberships.last.update(intent: 'off_campus')
      expect(draw.all_students_grouped?).to be_truthy
    end
    it 'returns true if there are no students in the draw not in a group' do
      draw = create(:draw_with_members, students_count: 1)
      create(:group, leader: draw.students.first)
      expect(draw.all_students_grouped?).to be_truthy
    end
  end

  describe '#ungrouped_students' do
    let(:draw) { create(:draw_with_members, students_count: 4) }

    before do
      create(:group, leader: draw.students.first)
      draw.draw_memberships[1].update!(intent: 'off_campus')
      draw.draw_memberships[2].update!(intent: 'undeclared')
    end
    it 'returns all students that do not belong to groups' do
      # Tried to use draw.students but it looks like changing those users
      # changes the order of the returned results (maybe orders by updated_at by
      # default?)
      expected = UngroupedStudentsQuery.new(
        draw.students.joins(:draw_memberships)
            .where(draw_memberships: { intent: %w(undeclared on_campus) })
      ).call
      expect(draw.ungrouped_students).to match_array(expected)
    end
  end

  describe '#all_intents_declared?' do
    let(:draw) { create(:draw_with_members) }

    it 'returns false if there are any undeclared students in the draw' do
      draw.draw_memberships.first.update(intent: 'undeclared')
      expect(draw.all_intents_declared?).to be_falsey
    end
    it 'returns true if there are no undeclared students in the draw' do
      draw.draw_memberships.first.update(intent: 'on_campus')
      expect(draw.all_intents_declared?).to be_truthy
    end
  end

  describe '#all_groups_locked?' do
    it 'returns true if all groups in the draw are locked' do
      draw = create(:draw_with_members, students_count: 1)
      create(:locked_group, leader: draw.students.first)
      expect(draw.all_groups_locked?).to be_truthy
    end
    it 'returns false if not all groups in the draw are locked' do
      draw = create(:draw_with_members, students_count: 2)
      create(:locked_group, leader: draw.students.first)
      create(:full_group, leader: draw.students.second)
      expect(draw.all_groups_locked?).to be_falsey
    end
  end

  describe '#no_contested_suites?' do
    xit 'returns true if there are no suites contested in other draws'
    xit 'returns false if there are any suites contested in other draws'
  end

  describe '#student_count' do
    xit 'returns the nuber of students in the draw'
  end

  describe '#group_count' do
    it 'returns the number of groups in the draw' do
      draw = create(:draw_with_members)
      create(:group, leader: draw.students.first)
      expect(draw.group_count).to eq(1)
    end
  end

  describe '#available_suite_count' do
    it 'returns number of available suites' do
      draw = create(:draw_with_members, suites_count: 2)
      create(:suite_assignment, suite: draw.suites.first, group: create(:group))
      expect(draw.available_suite_count).to eq(1)
    end
  end

  describe '#before_lottery?' do
    let(:draw) { build_stubbed(:draw) }

    it 'returns true if draw is a draft' do
      draw.status = 'draft'
      expect(draw).to be_before_lottery
    end
    it 'returns true if draw is in the intent_selection phase' do
      draw.status = 'intent_selection'
      expect(draw).to be_before_lottery
    end
    it 'returns true if draw is in the group-formation phase' do
      draw.status = 'group_formation'
      expect(draw).to be_before_lottery
    end
    it 'returns false if the draw is in the lottery phase' do
      draw.status = 'lottery'
      expect(draw).not_to be_before_lottery
    end
    it 'returns false if the draw is in the suite_selection phase' do
      draw.status = 'suite_selection'
      expect(draw).not_to be_before_lottery
    end
    it 'returns false if the draw is in the results phase' do
      draw.status = 'results'
      expect(draw).not_to be_before_lottery
    end
  end

  describe '#group_formation_or_later?' do
    let(:draw) { build_stubbed(:draw) }

    it 'returns false if draw is a draft' do
      draw.status = 'draft'
      expect(draw).not_to be_group_formation_or_later
    end
    it 'returns false if draw is in the intent_selection phase' do
      draw.status = 'intent_selection'
      expect(draw).not_to be_group_formation_or_later
    end
    it 'returns true if draw is in the group-formation phase' do
      draw.status = 'group_formation'
      expect(draw).to be_group_formation_or_later
    end
    it 'returns true if the draw is in the lottery phase' do
      draw.status = 'lottery'
      expect(draw).to be_group_formation_or_later
    end
    it 'returns true if the draw is in the suite_selection phase' do
      draw.status = 'suite_selection'
      expect(draw).to be_group_formation_or_later
    end
    it 'returns true if the draw is in the results phase' do
      draw.status = 'results'
      expect(draw).to be_group_formation_or_later
    end
  end

  describe '#lottery_or_later?' do
    let(:draw) { build_stubbed(:draw) }

    it 'returns false if draw is a draft' do
      draw.status = 'draft'
      expect(draw).not_to be_lottery_or_later
    end
    it 'returns false if draw is in the intent_selection phase' do
      draw.status = 'intent_selection'
      expect(draw).not_to be_lottery_or_later
    end
    it 'returns false if draw is in the group-formation phase' do
      draw.status = 'group_formation'
      expect(draw).not_to be_lottery_or_later
    end
    it 'returns true if the draw is in the lottery phase' do
      draw.status = 'lottery'
      expect(draw).to be_lottery_or_later
    end
    it 'returns true if the draw is in the suite_selection phase' do
      draw.status = 'suite_selection'
      expect(draw).to be_lottery_or_later
    end
    it 'returns true if the draw is in the results phase' do
      draw.status = 'results'
      expect(draw).to be_lottery_or_later
    end
  end

  describe '#oversubscribed?' do
    it 'returns true if the draw is oversubscribed' do
      draw = create(:oversubscribed_draw)
      expect(draw).to be_oversubscribed
    end

    it 'returns false if the draw is not oversubscribed' do
      draw = create(:draw_with_members, status: 'group_formation')
      create(:locked_group, leader: draw.students.first)
      expect(draw).not_to be_oversubscribed
    end

    it 'only counts avaiable suites' do
      draw = create(:draw_with_members, status: 'group_formation')
      create(:locked_group, leader: draw.students.first)
      # this assigns a suite in this draw to a group in another draw
      create(:group_with_suite, suite: draw.suites.last)
      expect(draw).to be_oversubscribed
    end
  end

  describe '#size_restricted?' do
    it 'returns true if the suite size is locked' do
      draw = build_stubbed(:draw, restricted_sizes: [1])
      expect(draw.size_restricted?(1)).to be_truthy
    end

    it 'returns false if the suite size is unlocked' do
      draw = build_stubbed(:draw, restricted_sizes: [])
      expect(draw.size_restricted?(1)).to be_falsey
    end
  end

  describe '#lottery_complete?' do
    let(:draw) { create(:draw_in_lottery) }

    it 'returns true if all groups have lottery numbers assigned' do
      draw.groups.each do |g|
        create(:lottery_assignment, :defined_by_group, group: g)
      end
      expect(draw.lottery_complete?).to be_truthy
    end
    it 'returns false if some groups do have lottery numbers assigned' do
      expect(draw.lottery_complete?).to be_falsey
    end
  end

  describe '#next_groups' do
    it 'calls NextGroupQuery' do
      draw = build_stubbed(:draw)
      allow(NextGroupsQuery).to receive(:call).with(draw: draw)
      draw.next_groups
      expect(NextGroupsQuery).to have_received(:call).with(draw: draw)
    end
  end

  describe '#next_group?' do
    it 'returns true when group is in next groups' do
      group = instance_spy('Group')
      draw = build_stubbed(:draw)
      allow(draw).to receive(:next_groups).and_return([group])
      expect(draw.next_group?(group)).to be_truthy
    end
    it 'returns false when group is not in next groups' do
      group = instance_spy('Group')
      draw = build_stubbed(:draw)
      allow(draw).to receive(:next_groups).and_return([])
      expect(draw.next_group?(group)).to be_falsey
    end
  end

  describe '#all_groups_have_suites?' do
    let(:draw) { create(:draw_in_selection, groups_count: 2) }

    before do
      create(:suite_assignment, suite: draw.suites.last,
                                group: draw.groups.last)
    end

    it 'returns true if all groups have suites assigned' do
      create(:suite_assignment, suite: draw.suites.first,
                                group: draw.groups.first)
      expect(draw.reload.all_groups_have_suites?).to be_truthy
    end
    it 'returns false if not all groups have suites assigned' do
      expect(draw.all_groups_have_suites?).to be_falsey
    end
  end

  describe '#students_with_intent' do
    it 'calls StudentsWithIntentQuery' do
      draw = build_stubbed(:draw)
      query = instance_spy('StudentsWithIntentQuery', call: [])
      allow(StudentsWithIntentQuery).to receive(:new).and_return(query)
      draw.students_with_intent(intents: %w(on_campus))
      expect(query).to have_received(:call).with(intents: %w(on_campus))
    end
  end
end
