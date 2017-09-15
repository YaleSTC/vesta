# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OversubscriptionPruner do
  describe 'validations' do
    it 'cannot prune sizes that are not oversubscribed' do
      draw = instance_spy('DrawReport', sizes: [1], oversubscribed_sizes: [])
      result = described_class.prune(draw_report: draw, sizes: [1])
      expect(result[:msg][:error]).to match(/Singles must be oversubscribed/)
    end

    it 'cannot prune sizes not in draw' do
      draw = instance_spy('DrawReport', sizes: [1], oversubscribed_sizes: [1])
      result = described_class.prune(draw_report: draw, sizes: [3])
      expect(result[:msg][:error]).to match(/Triples must be in the draw/)
    end
  end

  describe '#prune' do
    context 'success' do
      it 'prunes oversubscribed sizes' do
        sizes = [1, 2]
        draw = oversubscribed_draw(sizes: sizes)
        result = described_class.prune(draw_report: draw, sizes: sizes)
        expect(result[:msg][:success]).to \
          match(/Singles disbanded:.*Doubles disbanded:/)
      end

      it 'locks all oversubscribed sizes after pruning' do
        sizes = [1, 2]
        draw = oversubscribed_draw(sizes: sizes)
        described_class.prune(draw_report: draw, sizes: sizes)
        expect(draw.locked_sizes).to match_array(sizes)
      end

      it 'returns the draw in redirect_object when no longer oversubscribed' do
        sizes = [1, 2]
        draw = oversubscribed_draw(sizes: sizes)
        result = described_class.prune(draw_report: draw, sizes: sizes)
        expect(result[:redirect_object]).to eq(draw)
      end

      it 'returns nil in redirect_object when still oversubscribed' do
        draw = oversubscribed_draw(sizes: [1, 2])
        result = described_class.prune(draw_report: draw, sizes: [1])
        expect(result[:redirect_object]).to be_nil
      end
    end

    describe 'persistence error handling' do
      # rubocop:disable RSpec/ExampleLength
      it 'errors on failure to lock the size' do
        draw = oversubscribed_draw(sizes: [1])
        allow(draw).to receive(:save!)
          .and_raise(ActiveRecord::RecordInvalid.new(draw.__getobj__))
        pruner = pruner_valid_stubbed(draw_report: draw, sizes: [1])
        error_hash = { error: 'Oversubscription pruning failed: .' }
        expect(pruner.prune[:msg]).to eq(error_hash)
      end
      # rubocop:enable RSpec/ExampleLength

      it 'errors on failure to destroy groups' do
        error_msg = 'stub'
        draw = draw_stub_with_failed_destruction(size: 1, msg: error_msg)
        pruner = pruner_valid_stubbed(draw_report: draw, sizes: [1])
        error_hash = { error: "Oversubscription pruning failed: #{error_msg}." }
        expect(pruner.prune[:msg]).to eq(error_hash)
      end

      def draw_stub_with_failed_destruction(size: 1, msg:)
        errors = instance_spy(ActiveModel::Errors, full_messages: %W[#{msg}])
        group = instance_spy('group', errors: errors)
        exception = ActiveRecord::RecordNotDestroyed.new(nil, group)
        allow(group).to receive(:destroy!).and_raise(exception)
        groups = instance_spy('ActiveRecord::Associations::CollectionProxy',
                              where: [group])
        instance_spy('DrawReport',
                     groups: groups, oversubscription: { size => -1 })
      end
    end
  end

  def oversubscribed_draw(sizes: [1])
    draw = FactoryGirl.create(:draw, status: 'pre_lottery')
    sizes.each do |s|
      2.times { create(:locked_group, :defined_by_draw, draw: draw, size: s) }
    end
    draw.suites.delete_all
    sizes.each do |s|
      draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: s)
    end
    DrawReport.new(draw)
  end

  def pruner_valid_stubbed(draw_report:, sizes:)
    described_class.new(draw_report: draw_report, sizes: sizes).tap do |p|
      allow(p).to receive(:valid?).and_return(true)
    end
  end
end
