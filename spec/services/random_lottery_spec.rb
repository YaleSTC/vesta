# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RandomLottery do
  ERROR_PREFIX = 'Random lottery failed:'
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
        eq(error: "#{ERROR_PREFIX} draw must be in lottery")
    end
  end

  context 'failure to create lottery assignments' do
    let(:draw) do
      lottery = build_stubbed(:lottery_assignment)
      stub_errors(obj: lottery, msg: 'stub')
      allow(lottery).to receive(:save!)
        .and_raise(ActiveRecord::RecordInvalid.new(lottery))
      instance_spy(Draw, lottery?: true, lottery_assignments: []).tap do |d|
        allow(ObjectsForLotteryQuery).to receive(:call).with(draw: d)
                                                       .and_return([lottery])
      end
    end

    it 'returns the #create! errors in :msg' do
      result = described_class.run(draw: draw)
      expect(result[:msg]).to eq(error: "#{ERROR_PREFIX} stub")
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
      expect(result[:msg]).to eq(error: "#{ERROR_PREFIX} stub")
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
