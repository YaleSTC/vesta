# frozen_string_literal: true
require 'spec_helper'

RSpec.describe DrawSelectionStarter do
  # we may want to extract this into a shared example if we use this pattern
  # across all of our service objects
  describe '.start' do
    it 'calls :start on an instance of DrawStarter' do
      draw = instance_spy('draw')
      draw_selection_starter = mock_draw_selection_starter(draw: draw)
      described_class.start(draw: draw)
      expect(draw_selection_starter).to have_received(:start)
    end
  end

  describe '#start' do
    it 'checks to make sure that the draw is in lottery' do
      draw = instance_spy('draw', lottery?: false)
      result = described_class.start(draw: draw)
      expect(result[:msg][:error]).to include('in the lottery phase')
    end

    it 'checks to make sure that all groups have lottery numbers assigned' do
      draw = instance_spy('draw', lottery_complete?: false)
      result = described_class.start(draw: draw)
      expect(result[:msg][:error]).to \
        include('All groups must have lottery numbers assigned')
    end

    it 'updates the status of the draw to suite_selection' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      allow(draw).to receive(:update).with(status: 'suite_selection')
        .and_return(true)
      described_class.start(draw: draw)
      expect(draw).to have_received(:update).with(status: 'suite_selection')
    end

    it 'checks to see if the update works' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      allow(draw).to receive(:update).and_return(false)
      result = described_class.start(draw: draw)
      expect(result[:msg][:error]).to include('Draw update failed')
    end

    it 'returns the updated draw on success' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      result = described_class.start(draw: draw)
      expect(result[:object]).to eq(draw)
    end

    it 'sends invitations to the first group(s) to select' do
      draw = valid_mock_draw_with_group
      mailer = instance_spy('student_mailer')
      described_class.start(draw: draw, mailer: mailer)
      expect(mailer).to have_received(:selection_invite).once
    end

    it 'sets the object key to nil in the hash on failure' do
      draw = instance_spy('draw', validity_stubs(valid: false))
      result = described_class.start(draw: draw)
      expect(result[:object]).to be_nil
    end
  end

  def mock_draw_selection_starter(param_hash)
    instance_spy('draw_selection_starter').tap do |draw_selection_starter|
      allow(described_class).to receive(:new).with(param_hash)
        .and_return(draw_selection_starter)
    end
  end

  def validity_stubs(valid:, **attrs)
    { lottery?: valid, lottery_complete?: valid }.merge(attrs)
  end

  def valid_mock_draw_with_group
    group = instance_spy('group', leader: instance_spy('user'))
    instance_spy('draw', validity_stubs(valid: true, next_groups: [group]))
  end
end
