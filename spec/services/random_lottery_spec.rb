# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RandomLottery do
  # rubocop:disable RSpec/NestedGroups
  describe 'sorted lottery' do
    let(:draw) { create(:draw, status: 'lottery') }

    # This creates two groups of size 1 and 3 and a clip with groups of size
    #   2 and 4
    before { seed_clips_and_groups }
    after do
      College.current.update!(size_sort: 'no_sort', advantage_clips: false)
    end

    context 'ascending sort' do
      before { College.current.update!(size_sort: 'ascending') }

      context 'advantaged clips' do
        before { College.current.update!(advantage_clips: true) }

        it 'assigns lottery numbers correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          # sorting by min size gives clips an advantage since smaller groups
          #   are given earlier numbers when sorted ascending
          sorted = la.sort_by { |l| l.groups.map(&:size).min }
          expect(sorted.map(&:number)).to eq([1, 2, 3])
        end

        it 'sorts groups and clips correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          sorted = la.sort_by(&:number)
          expect(sorted.map { |l| l.clip.present? }).to eq([false, true, false])
        end
      end

      context 'disadvantaged clips' do
        before { College.current.update!(advantage_clips: false) }

        it 'assigns lottery numbers correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          # sorting by max size gives clips a disadvantage since smaller groups
          #   are given earlier numbers when sorted ascending
          sorted = la.sort_by { |l| l.groups.map(&:size).max }
          expect(sorted.map(&:number)).to eq([1, 2, 3])
        end

        it 'sorts groups and clips correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          sorted = la.sort_by(&:number)
          expect(sorted.map { |l| l.clip.present? }).to eq([false, false, true])
        end
      end
    end

    context 'descending sort' do
      before { College.current.update!(size_sort: 'descending') }

      context 'advantaged clips' do
        before { College.current.update!(advantage_clips: true) }

        it 'assigns lottery numbers correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          # sorting by max size gives clips an advantage since larger groups
          #   are given earlier numbers when sorted descending
          sorted = la.sort_by { |l| l.groups.map(&:size).max }
          expect(sorted.map(&:number)).to eq([3, 2, 1])
        end

        it 'sorts groups and clips correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          sorted = la.sort_by(&:number)
          expect(sorted.map { |l| l.clip.present? }).to eq([true, false, false])
        end
      end

      context 'disadvantaged clips' do
        before { College.current.update!(advantage_clips: false) }

        it 'assigns lottery numbers correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          # sorting by min size gives clips an advantage since larger groups
          #   are given earlier numbers when sorted descending
          sorted = la.sort_by { |l| l.groups.map(&:size).min }
          expect(sorted.map(&:number)).to eq([3, 2, 1])
        end

        it 'sorts groups and clips correctly' do
          described_class.run(draw: draw)
          la = LotteryAssignment.all
          sorted = la.sort_by(&:number)
          expect(sorted.map { |l| l.clip.present? }).to eq([false, true, false])
        end
      end
    end

    def seed_clips_and_groups
      create(:group, :defined_by_draw, draw: draw, size: 1)
      group1 = create(:group, :defined_by_draw, draw: draw, size: 2)
      create(:group, :defined_by_draw, draw: draw, size: 3)
      group2 = create(:group, :defined_by_draw, draw: draw, size: 4)
      create(:clip, draw: draw, groups: [group1, group2])
    end
  end
  # rubocop:enable RSpec/NestedGroups

  context 'success' do
    it 'starts suite selection on the draw' do
      draw = create(:draw_in_lottery)
      expect { described_class.run(draw: draw) }.to \
        change { draw.suite_selection? }.from(false).to(true)
    end
    it 'returns a success message' do
      draw = valid_mock_draw
      allow(DrawSelectionStarter).to receive(:start!).with(draw: draw)
      result = described_class.run(draw: draw)
      expect(result[:msg].keys).to eq(%i(success))
    end
    it 'creates a lottery assignment for each group/clip' do
      draw = create(:draw_in_lottery)
      count = ObjectsForLotteryQuery.call(draw: draw).count
      expect { described_class.run(draw: draw) }.to \
        change { LotteryAssignment.count }.by(count)
    end
    it 'sets the views via ObjectsForLotteryQuery' do
      draw = valid_mock_draw
      described_class.run(draw: draw)
      expect(ObjectsForLotteryQuery).to have_received(:call).with(draw: draw)
    end
    it 'returns the draw in :redirect_object' do
      draw = valid_mock_draw
      result = described_class.run(draw: draw)
      expect(result[:redirect_object]).to eq(draw)
    end
    xit 'destroys existing lottery assignments before assigning numbers'
  end

  describe 'validations' do
    it 'must be a draw in lottery' do
      draw = instance_spy('Draw', lottery?: false)
      allow(ObjectsForLotteryQuery).to receive(:call).with(draw: draw)
      result = described_class.run(draw: draw)
      expect(result[:msg]).to \
        eq(error: 'Random lottery failed: draw must be in lottery')
    end
  end

  context 'failure to create lottery assignments' do
    let(:draw) do
      lottery = build_stubbed(:lottery_assignment)
      stub_errors(obj: lottery, msg: 'stub')
      allow(lottery).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(lottery))
      instance_spy(Draw, lottery?: true, lottery_assignments: []).tap do |d|
        allow(ObjectsForLotteryQuery).to receive(:call).with(draw: d)
                                                       .and_return([lottery])
      end
    end

    it 'returns the #create! errors in :msg' do
      result = described_class.run(draw: draw)
      expect(result[:msg]).to eq(error: 'Random lottery failed: stub')
    end
    it 'returns draw in :redirect_object' do
      result = described_class.run(draw: draw)
      expect(result[:redirect_object]).to eq(draw)
    end
  end

  context 'failure to start suite selection' do
    it 'returns the service errors in :msg' do
      draw = create(:draw_in_lottery)
      stub_update_failure(draw)
      stub_errors(obj: draw, msg: 'stub')
      result = described_class.run(draw: draw)
      expect(result[:msg]).to eq(error: 'Random lottery failed: stub')
    end
    it 'handles starter validation failures' do
      draw = create(:draw_in_lottery)
      allow(draw).to receive(:lottery_complete?).and_return(false)
      result = described_class.run(draw: draw)
      expect(result[:msg].keys).to eq(%i(error))
    end
    it 'returns draw in :redirect_object' do
      draw = create(:draw_in_lottery)
      stub_update_failure(draw)
      stub_errors(obj: draw, msg: 'stub')
      result = described_class.run(draw: draw)
      expect(result[:redirect_object]).to eq(draw)
    end
    it 'rolls back properly' do
      draw = create(:draw_in_lottery)
      allow(draw).to receive(:lottery_complete?).and_return(false)
      expect { described_class.run(draw: draw) }.not_to \
        change { LotteryAssignment.count }
    end

    def stub_update_failure(draw)
      allow(draw).to receive(:update!)
        .with(status: 'suite_selection')
        .and_raise(ActiveRecord::RecordInvalid.new(draw))
    end
  end

  def stub_errors(obj:, msg:)
    errors = instance_spy(ActiveModel::Errors, full_messages: %W[#{msg}])
    allow(obj).to receive(:errors).and_return(errors)
  end

  def valid_mock_draw
    # persisting data because of the lottery notification e-mail
    create(:draw_in_lottery).tap do |d|
      allow(ObjectsForLotteryQuery).to \
        receive(:call).with(draw: d).and_return([])
    end
  end
end
