# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawResultsStarter do
  describe '#start' do
    it 'checks to make sure that the draw is in selection' do
      draw = instance_spy('draw', suite_selection?: false)
      result = described_class.start(draw: draw)
      expect(result[:msg][:error]).to include('in the selection phase')
    end
    it 'checks to make sure that all groups have suites' do
      draw = instance_spy('draw', all_groups_have_suites?: false)
      result = described_class.start(draw: draw)
      expect(result[:msg][:error]).to include('must have suites selected')
    end
    it 'updates the status of the draw to results' do
      draw = instance_spy('draw', validity_stubs(valid: true, update!: true))
      described_class.start(draw: draw)
      expect(draw).to have_received(:update!).with(status: 'results')
    end
    it 'rescues update! exceptions' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      error = ActiveRecord::RecordInvalid.new(FactoryGirl.build_stubbed(:draw))
      allow(draw).to receive(:update!).and_raise(error)
      result = described_class.start(draw: draw)
      expect(result[:msg][:error]).to include('There was a problem')
    end
    it 'returns the updated draw on success' do
      draw = instance_spy('draw', validity_stubs(valid: true,
                                                 all_students_grouped?: true))
      result = described_class.start(draw: draw)
      expect(result[:redirect_object]).to eq(draw)
    end
    it 'sets a success message' do
      draw = instance_spy('draw', validity_stubs(valid: true,
                                                 all_students_grouped?: true))
      result = described_class.start(draw: draw)
      expect(result[:msg].keys).to eq([:success])
    end

    context 'secondary draw creation' do
      let(:draw) { FactoryGirl.create(:draw_in_selection, groups_count: 2) }

      before do
        draw.groups.first.destroy!
        draw.suites.first.update!(group_id: draw.groups.first.id)
      end

      it 'occurs if necessary' do
        expect { described_class.start(draw: draw) }.to change(Draw, :count)
      end
      it 'transfers the ungrouped students' do
        expected = draw.ungrouped_students.map(&:id)
        described_class.start(draw: draw)
        expect(Draw.last.students.map(&:id)).to match_array(expected)
      end
      it 'transfers the unassigned suites' do
        expected = draw.suites.available.map(&:id)
        described_class.start(draw: draw)
        expect(Draw.last.suites.map(&:id)).to match_array(expected)
      end
      it 'sets a notice as well as a success message' do
        result = described_class.start(draw: draw)
        expect(result[:msg].keys).to match_array(%i(success notice))
      end
    end

    it 'sets the object key to nil in the hash on failure' do
      draw = instance_spy('draw', validity_stubs(valid: false))
      result = described_class.start(draw: draw)
      expect(result[:redirect_object]).to be_nil
    end
  end

  def mock_draw_results_starter(param_hash)
    instance_spy('draw_results_starter').tap do |draw_results_starter|
      allow(described_class).to receive(:new).with(param_hash)
                                             .and_return(draw_results_starter)
    end
  end

  def validity_stubs(valid:, **attrs)
    { suite_selection?: valid, all_groups_have_suites?: valid }.merge(attrs)
  end
end
