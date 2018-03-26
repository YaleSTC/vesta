# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Draw, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:students) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:draw_suites) }
    it { is_expected.to have_many(:lottery_assignments) }
    it { is_expected.to have_many(:clips) }
    it { is_expected.to have_many(:suites).through(:draw_suites) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:suite_selection_mode) }

    it 'cannot lock intent if undeclared students' do
      draw = FactoryGirl.create(:draw, status: 'pre_lottery')
      draw.students << FactoryGirl.create(:student, intent: 'undeclared')
      draw.intent_locked = true
      expect(draw).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'nullifies the draw_id field on users in the draw after destroy' do
      draw = FactoryGirl.create(:draw_with_members)
      students = draw.students
      draw.destroy
      expect(students.map(&:reload).map(&:draw_id).all?(&:nil?)).to be_truthy
    end
    it 'clears old_draw_id when necessary' do
      draw = FactoryGirl.create(:draw)
      student = FactoryGirl.create(:student, old_draw_id: draw.id)
      draw.destroy
      expect(student.reload.old_draw_id).to be_nil
    end
  end

  describe '#suite_sizes' do
    let(:draw) { FactoryGirl.build_stubbed(:draw) }

    it 'returns an array of all the available suite sizes in the draw' do
      instance_spy('SuiteSizesQuery', call: [1, 2]).tap do |q|
        allow(SuiteSizesQuery).to receive(:new).with(draw.suites.available)
                                               .and_return(q)
      end
      expect(draw.suite_sizes).to match_array([1, 2])
    end
  end

  describe '#group_sizes' do
    let(:draw) { FactoryGirl.build_stubbed(:draw) }

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
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:students).and_return(students)
      expect(draw.send(:student_count)).to eq(3)
    end
  end

  describe '#students?' do
    it 'returns true if the student_count is greater than zero' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:student_count).and_return(1)
      expect(draw.students?).to be_truthy
    end

    it 'returns false if the student_count is zero' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:student_count).and_return(0)
      expect(draw.students?).to be_falsey
    end
  end

  describe '#groups?' do
    it 'returns true if the group_count is greater than zero' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:group_count).and_return(1)
      expect(draw.groups?).to be_truthy
    end

    it 'returns false if the group_count is zero' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:group_count).and_return(0)
      expect(draw.groups?).to be_falsey
    end
  end

  describe '#enough_beds?' do
    it 'returns true if bed_count >= on_campus_student_count' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:bed_count).and_return(2)
      allow(draw).to receive(:on_campus_student_count).and_return(1)
      expect(draw.enough_beds?).to be_truthy
    end

    it 'returns false if bed_count < on_campus_student_count' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:bed_count).and_return(1)
      allow(draw).to receive(:on_campus_student_count).and_return(2)
      expect(draw.enough_beds?).to be_falsey
    end
  end

  describe '#open_suite_sizes' do
    it 'returns suite sizes in the draw minus locked sizes' do
      draw = FactoryGirl.build_stubbed(:draw, locked_sizes: [1])
      all_sizes = [1, 2]
      allow(draw).to receive(:suite_sizes).and_return(all_sizes)
      expect(draw.open_suite_sizes).to eq([2])
    end
  end

  describe '#bed_count' do
    it 'returns the number of beds across all available suites' do
      draw = FactoryGirl.create(:draw_with_members, suites_count: 2)
      group = FactoryGirl.create(:locked_group, :defined_by_draw, draw: draw)
      draw.reload.suites.last.update(group: group)
      available_beds = draw.suites.sum(&:size) - draw.suites.last.size
      expect(draw.send(:bed_count)).to eq(available_beds)
    end
  end

  describe '#available_suites' do
    it 'returns suites without associated groups' do
      available = FactoryGirl.create(:suite)
      taken = FactoryGirl.create(:group_with_suite).suite
      draw = FactoryGirl.create(:draw, suites: [available, taken])
      expect(draw.available_suites).to eq([available])
    end
  end

  describe '#all_students_grouped?' do
    it 'returns false if there are students in the draw not in a group' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 2)
      FactoryGirl.create(:group, leader: draw.students.first)
      expect(draw.all_students_grouped?).to be_falsey
    end
    it 'checks undeclared students' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 2)
      FactoryGirl.create(:group, leader: draw.students.first)
      draw.students.last.update(intent: 'undeclared')
      expect(draw.all_students_grouped?).to be_falsey
    end
    it 'ignores off_campus students' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 2)
      FactoryGirl.create(:group, leader: draw.students.first)
      draw.students.last.update(intent: 'off_campus')
      expect(draw.all_students_grouped?).to be_truthy
    end
    it 'returns true if there are no students in the draw not in a group' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 1)
      FactoryGirl.create(:group, leader: draw.students.first)
      expect(draw.all_students_grouped?).to be_truthy
    end
  end

  describe '#ungrouped_students' do
    let(:draw) { FactoryGirl.create(:draw_with_members, students_count: 4) }

    before do
      FactoryGirl.create(:group, leader: draw.students.first)
      draw.students[1].update!(intent: 'off_campus')
      draw.students[2].update!(intent: 'undeclared')
    end
    it 'returns all students that do not belong to groups' do
      # Tried to use draw.students but it looks like changing those users
      # changes the order of the returned results (maybe orders by updated_at by
      # default?)
      expected = UngroupedStudentsQuery.new(
        draw.students.where(intent: %w(undeclared on_campus))
      ).call
      expect(draw.ungrouped_students).to match_array(expected)
    end
  end

  describe '#all_intents_declared?' do
    let(:draw) { FactoryGirl.create(:draw_with_members) }

    it 'returns false if there are any undeclared students in the draw' do
      draw.students.first.update(intent: 'undeclared')
      expect(draw.all_intents_declared?).to be_falsey
    end
    it 'returns true if there are no undeclared students in the draw' do
      draw.students.first.update(intent: 'on_campus')
      expect(draw.all_intents_declared?).to be_truthy
    end
  end

  describe '#all_groups_locked?' do
    it 'returns true if all groups in the draw are locked' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 1)
      FactoryGirl.create(:locked_group, leader: draw.students.first)
      expect(draw.all_groups_locked?).to be_truthy
    end
    it 'returns false if not all groups in the draw are locked' do
      draw = FactoryGirl.create(:draw_with_members, students_count: 2)
      FactoryGirl.create(:locked_group, leader: draw.students.first)
      FactoryGirl.create(:full_group, leader: draw.students.second)
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
      draw = FactoryGirl.create(:draw_with_members)
      FactoryGirl.create(:group, leader: draw.students.first)
      expect(draw.group_count).to eq(1)
    end
  end

  describe '#available_suite_count' do
    it 'returns number of available suites' do
      draw = FactoryGirl.create(:draw_with_members, suites_count: 2)
      draw.suites.first.update!(group_id: FactoryGirl.create(:group).id)
      expect(draw.available_suite_count).to eq(1)
    end
  end

  describe '#before_lottery?' do
    let(:draw) { FactoryGirl.build_stubbed(:draw) }

    it 'returns true if draw is a draft' do
      draw.status = 'draft'
      expect(draw).to be_before_lottery
    end
    it 'returns true if draw is in the pre_lottery phase' do
      draw.status = 'pre_lottery'
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

  describe '#lottery_or_later?' do
    let(:draw) { FactoryGirl.build_stubbed(:draw) }

    it 'returns true if draw is a draft' do
      draw.status = 'draft'
      expect(draw).not_to be_lottery_or_later
    end
    it 'returns true if draw is in the pre_lottery phase' do
      draw.status = 'pre_lottery'
      expect(draw).not_to be_lottery_or_later
    end
    it 'returns false if the draw is in the lottery phase' do
      draw.status = 'lottery'
      expect(draw).to be_lottery_or_later
    end
    it 'returns false if the draw is in the suite_selection phase' do
      draw.status = 'suite_selection'
      expect(draw).to be_lottery_or_later
    end
    it 'returns false if the draw is in the results phase' do
      draw.status = 'results'
      expect(draw).to be_lottery_or_later
    end
  end

  describe '#oversubscribed?' do
    it 'returns true if the draw is oversubscribed' do
      draw = FactoryGirl.create(:oversubscribed_draw)
      expect(draw).to be_oversubscribed
    end

    it 'returns false if the draw is not oversubscribed' do
      draw = FactoryGirl.create(:draw_with_members, status: 'pre_lottery')
      FactoryGirl.create(:locked_group, leader: draw.students.first)
      expect(draw).not_to be_oversubscribed
    end
  end

  describe '#size_locked?' do
    it 'returns true if the suite size is locked' do
      draw = FactoryGirl.build_stubbed(:draw, locked_sizes: [1])
      expect(draw.size_locked?(1)).to be_truthy
    end

    it 'returns false if the suite size is unlocked' do
      draw = FactoryGirl.build_stubbed(:draw, locked_sizes: [])
      expect(draw.size_locked?(1)).to be_falsey
    end
  end

  describe '#lottery_complete?' do
    let(:draw) { FactoryGirl.create(:draw_in_lottery) }

    it 'returns true if all groups have lottery numbers assigned' do
      draw.groups.each do |g|
        FactoryGirl.create(:lottery_assignment, :defined_by_group, group: g)
      end
      expect(draw.lottery_complete?).to be_truthy
    end
    it 'returns false if some groups do have lottery numbers assigned' do
      expect(draw.lottery_complete?).to be_falsey
    end
  end

  describe '#next_groups' do
    it 'calls NextGroupQuery' do
      draw = FactoryGirl.build_stubbed(:draw)
      allow(NextGroupsQuery).to receive(:call).with(draw: draw)
      draw.next_groups
      expect(NextGroupsQuery).to have_received(:call).with(draw: draw)
    end
  end

  describe '#next_group?' do
    it 'returns true when group is in next groups' do
      group = instance_spy('Group')
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:next_groups).and_return([group])
      expect(draw.next_group?(group)).to be_truthy
    end
    it 'returns false when group is not in next groups' do
      group = instance_spy('Group')
      draw = FactoryGirl.build_stubbed(:draw)
      allow(draw).to receive(:next_groups).and_return([])
      expect(draw.next_group?(group)).to be_falsey
    end
  end

  describe '#notify_next_groups' do
    # rubocop:disable RSpec/ExampleLength
    it 'sends a selection invite to the leaders of the next groups' do
      draw = build_stubbed(:draw, suite_selection_mode: 'student_selection')
      group = instance_spy('Group', leader: instance_spy('User'))
      allow(draw).to receive(:next_groups).and_return([group])
      msg = instance_spy(ActionMailer::MessageDelivery, deliver_later: true)
      allow(StudentMailer).to receive(:selection_invite).and_return(msg)
      draw.notify_next_groups(StudentMailer)
      expect(StudentMailer).to \
        have_received(:selection_invite).with(user: group.leader)
    end
    it 'does not send emails when admin selection mode is enabled' do
      draw = build_stubbed(:draw, suite_selection_mode: 'admin_selection')
      group = instance_spy('Group', leader: instance_spy('User'))
      allow(draw).to receive(:next_groups).and_return([group])
      allow(StudentMailer).to receive(:selection_invite)
      draw.notify_next_groups(StudentMailer)
      expect(StudentMailer).not_to have_received(:selection_invite)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#all_groups_have_suites?' do
    let(:draw) { FactoryGirl.create(:draw_in_selection, groups_count: 2) }

    before { draw.suites.last.update!(group_id: draw.groups.last.id) }
    it 'returns true if all groups have suites assigned' do
      draw.suites.first.update!(group_id: draw.groups.first.id)
      expect(draw.reload.all_groups_have_suites?).to be_truthy
    end
    it 'returns false if not all groups have suites assigned' do
      expect(draw.all_groups_have_suites?).to be_falsey
    end
  end
end
