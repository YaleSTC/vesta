# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Suite, type: :model do
  describe 'basic associations and validations' do
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to belong_to(:building) }
    it { is_expected.to have_many(:suite_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:suite_assignments) }
    it { is_expected.to have_one(:suite_assignment) }
    it { is_expected.to have_one(:group).through(:suite_assignment) }
    it { is_expected.to have_many(:rooms).dependent(:nullify) }
    it { is_expected.to have_many(:draw_suites).dependent(:delete_all) }
    it { is_expected.to have_many(:draws).through(:draw_suites) }

    describe 'number uniqueness' do
      it 'allows duplicates that belong to separate buildings' do
        number = 'L01'
        create(:suite, number: number)
        suite = build(:suite, number: number)
        expect(suite.valid?).to be_truthy
      end
      it 'does not allow duplicates in the same building' do
        attrs = { number: 'L01', building: create(:building) }
        create(:suite, **attrs)
        suite = build(:suite, **attrs)
        expect(suite.valid?).to be_falsey
      end
    end
  end

  describe 'group association' do
    let(:group) { create(:drawless_group) }
    let(:suite) { create(:suite, size: group.size) }

    before { group.update!(suite: suite) }

    context 'when group is active' do
      before do
        group.draw_memberships.map { |dm| dm.update!(active: true) }
        group.leader_draw_membership.update!(active: true)
      end

      it 'returns the group' do
        expect(suite.reload.group.id).to eq(group.id)
      end
    end
    context 'when group is archived' do
      before do
        group.draw_memberships.map { |dm| dm.update!(active: false) }
        group.leader_draw_membership.update!(active: false)
      end

      it 'does not return a record' do
        expect(suite.reload.group).to be_nil
      end
    end
  end

  context 'scopes' do
    describe '.unavailable' do
      it 'returns suites assigned to active groups' do
        suite = create(:group_with_suite).reload.suite
        expect(described_class.unavailable).to match_array([suite])
      end
      it 'does not return suites assigned to archived groups' do
        g = create(:group_with_suite)
        g.draw.update!(active: false)
        expect(described_class.unavailable).to match_array([])
      end
      it 'does not return suites that have never been assigned to groups' do
        create(:suite_with_rooms)
        expect(described_class.unavailable).to match_array([])
      end
    end

    describe '.available' do
      it 'returns all suites not assigned to groups' do
        available = create(:suite)
        create(:group_with_suite)
        expect(described_class.available).to match_array([available])
      end

      it 'returns previously assigned suites with archived draws' do
        available = suite_with_archived_group
        create_archived_special_group_for_suite(available)
        expect(described_class.available).to match_array([available])
      end

      it 'does not return unavailable suites with previously archived groups' do
        unavailable = create(:group_with_suite).reload.suite
        create_archived_special_group_for_suite(unavailable)
        expect(described_class.available).to match_array([])
      end

      def suite_with_archived_group
        g = create(:group_with_suite)
        available = g.reload.suite
        g.draw.update!(active: false)
        available
      end

      def create_archived_special_group_for_suite(suite)
        group = create(:drawless_group)
        Suite.last.destroy! # drawless group factory creates an extra suite
        create(:suite_assignment, group: group, suite: suite)
        group.memberships.map { |m| m.draw_membership.update!(active: false) }
      end
    end
  end

  describe 'before_save callbacks' do
    context 'if medical status changes' do
      let(:suite) { create(:suite) }

      it 'removes draws if changed to a medical suite' do
        draw = create(:draw)
        suite.update(draws: [draw])
        expect { suite.update!(medical: true) }.to \
          change { suite.draws.to_a }.to([])
      end
      it 'raises an error when unable to remove draw from medical suites' do
        draw = instance_spy('draw', update: ActiveRecord::RecordInvalid.new)
        allow(suite).to receive(:draws).and_return([draw])
        suite.update(medical: true)
        expect(suite.errors[:base])
          .to include('Unable to clear draws from medical suites')
      end
    end
  end

  describe '.size_str' do
    it 'raises an argument error if a non-integer is passed' do
      size = instance_spy('string')
      allow(size).to receive(:is_a?).with(Integer).and_return(false)
      expect { described_class.size_str(size) }.to raise_error(ArgumentError)
    end
    it 'raises an argument error if a non-positive number is passed' do
      size = instance_spy('integer')
      allow(size).to receive(:positive?).and_return(false)
      expect { described_class.size_str(size) }.to raise_error(ArgumentError)
    end
    context 'valid inputs' do
      expected = { 1 => 'single', 2 => 'double', 3 => 'triple',
                   4 => 'quad', 5 => 'quint', 6 => 'sextet',
                   7 => 'septet', 8 => 'octet', 9 => '9-pack' }
      expected.each do |size, expected_str|
        it "returns a valid result for #{size}" do
          expect(described_class.size_str(size)).to eq(expected_str)
        end
      end
    end
  end

  describe '#size' do
    it { is_expected.to validate_presence_of(:size) }
    it { is_expected.not_to allow_value(-1).for(:size) }
    it { is_expected.to allow_value(0).for(:size) }
    it 'equals the number of beds in all rooms' do
      size = 2
      suite = create(:suite)
      size.times { create(:room, beds: 1, suite: suite) }
      expect(suite.size).to eq(size)
    end
  end

  describe '#name_with_draws' do
    it 'returns the name if the suite belongs to no draws' do
      suite = build_stubbed(:suite)
      allow(suite).to receive(:draws).and_return([])
      expect(suite.name_with_draws).to eq(suite.name)
    end
    it 'returns the name if the suite only belongs to the passed draw' do
      suite = create(:suite)
      draw = create(:draw)
      suite.draws << draw
      expect(suite.name_with_draws(draw)).to eq(suite.name)
    end
    it 'ignores archived draws' do
      suite = create(:suite)
      draw = create(:draw)
      suite.draws << draw
      draw.update!(active: false)
      expect(suite.name_with_draws).to eq(suite.name)
    end
    it 'returns the name with other draw names' do
      suite = create(:suite)
      draw = create(:draw)
      suite.draws << draw
      expected = "#{suite.name} (#{draw.name})"
      expect(suite.name_with_draws).to eq(expected)
    end
    it 'excludes the passed draw' do
      draw = create(:draw_with_members, suites_count: 1,
                                        students_count: 0)
      draw2 = create(:draw)
      expected = "#{draw.suites.first.name} (#{draw.name})"
      expect(draw.suites.first.name_with_draws(draw2)).to eq(expected)
    end
  end

  describe '#available?' do
    it 'returns true if the suite has no group assigned' do
      suite = build(:suite, group: nil)
      expect(suite).to be_available
    end
    it 'returns false if the suite has a group assigned' do
      suite = build(:suite, group: build(:group))
      expect(suite).not_to be_available
    end
  end

  describe 'room helpers' do
    let(:suite) { create(:suite) }
    let(:single) { create(:single) }
    let(:double) { create(:double) }
    let(:common) { create(:room, beds: 0) }

    before do
      suite.rooms << single
      suite.rooms << double
      suite.rooms << common
    end

    describe '#singles' do
      it 'returns all of the single rooms belonging to the suite' do
        expect(suite.singles).to eq([single])
      end
    end
    describe '#doubles' do
      it 'returns all of the double rooms belonging to the suite' do
        expect(suite.doubles).to eq([double])
      end
    end
    describe '#common_rooms' do
      it 'returns all of the common rooms belonging to the suite' do
        expect(suite.common_rooms).to eq([common])
      end
    end
  end

  describe '#selectable?' do
    it "returns true if the suite isn't selectable in another draw" do
      suite = build_stubbed(:suite)
      allow(suite).to receive(:draws)
        .and_return(mock_draws(%i(group_formation? draft?)))
      expect(suite).to be_selectable
    end

    it "returns false if one of the suite's draws is in the lottery phase" do
      suite = build_stubbed(:suite)
      allow(suite).to receive(:draws)
        .and_return(mock_draws(%i(group_formation? draft? lottery?)))
      expect(suite).not_to be_selectable
    end

    it 'returns false if a draw is in the suite_selection phase' do
      suite = build_stubbed(:suite)
      allow(suite).to receive(:draws)
        .and_return(mock_draws(%i(group_formation? draft? suite_selection?)))
      expect(suite).not_to be_selectable
    end

    it 'ignores archived draws' do
      suite = create(:suite)
      suite.draws << create(:draw_in_lottery)
      suite.draws << create(:draw_in_selection)
      suite.draws.each { |d| d.reload.update!(active: false) }
      expect(suite).to be_selectable
    end

    def mock_draws(statuses)
      default_statuses = { draft?: false, group_formation?: false,
                           lottery?: false, suite_selection?: false }
      draws = instance_spy(ActiveRecord::Associations::CollectionProxy)
      array = statuses.map do |s|
        status_hash = default_statuses.merge(s => true)
        instance_spy('draw', **status_hash)
      end
      # We assume all mock draws are active
      allow(draws).to receive(:where).and_return(array)
      draws
    end
  end

  describe '#number_with_medical' do
    let(:suite) { build_stubbed(:suite) }

    it 'returns the number if not a medical suite' do
      allow(suite).to receive(:medical).and_return(false)
      expect(suite.number_with_medical).to eq(suite.number)
    end
    it 'indicates if the suite is a medical suite' do
      allow(suite).to receive(:medical).and_return(true)
      expected = "#{suite.number} (medical)"
      expect(suite.number_with_medical).to eq(expected)
    end
  end

  describe '#name' do
    let(:suite) { build_stubbed(:suite) }
    let(:building) { suite.building }

    it 'returns the building name and suite number' do
      expected = "#{building.name} #{suite.number}"
      expect(suite.name).to eq(expected)
    end
  end

  describe '#name_with_medical' do
    let(:suite) { build_stubbed(:suite) }
    let(:building) { suite.building }

    it 'returns the building name and suite number' do
      allow(suite).to receive(:medical).and_return(true)
      expected = "#{building.name} #{suite.number} (medical)"
      expect(suite.name_with_medical).to eq(expected)
    end
    it 'returns the name if not a medical suite' do
      allow(suite).to receive(:medical).and_return(false)
      expect(suite.name_with_medical).to eq(suite.name)
    end
  end

  describe 'lottery assignment callbacks' do
    # really don't like this but it's the simplest place for it to go
    it 'updates the selected attr on the lottery assignment' do
      lottery = create(:lottery_assignment)
      group = lottery.groups.first
      suite = group.draw.suites.first
      expect { suite.update(group: group) }.to \
        change { lottery.reload.selected }.from(false).to(true)
    end
  end
end
