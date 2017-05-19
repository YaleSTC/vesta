# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkOnCampusUpdater do
  let(:draw) { FactoryGirl.create(:draw_with_members, students_count: 2) }

  describe '#update' do
    it 'assigns all students intent to on_campus' do
      described_class.update(draw: draw)
      expect(draw.students.map(&:intent).uniq).to eq(['on_campus'])
    end
    it 'ignores off-campus students' do
      off_campus = draw.students.first
      off_campus.update(intent: 'off_campus')
      expect { described_class.update(draw: draw) }.not_to \
        change { off_campus.reload.intent }
    end
    it 'sets the :redirect_object to the draw' do
      result = described_class.update(draw: draw)
      expect(result[:redirect_object]).to eq(draw)
    end
    it 'sets a success message' do
      result = described_class.update(draw: draw)
      expect(result[:msg].keys).to eq([:success])
    end
  end
end
