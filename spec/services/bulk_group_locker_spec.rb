# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkGroupLocker do
  describe '#update' do
    it 'returns success flash' do
      draw = create(:draw_with_groups)
      expect(described_class.update(draw: draw)[:msg].keys).to eq([:success])
    end

    it 'locks "closed" and "finalizing" groups' do
      # groups are 'locked', 'open', 'finalizing', and 'full'
      draw = create(:draw_with_groups)
      described_class.update(draw: draw)
      expect(draw.groups.where(status: 'locked').length).to eq(3)
    end

    it 'errors for oversubscribed draws' do
      draw = create(:oversubscribed_draw)
      expect(described_class.update(draw: draw)[:msg].keys).to eq([:error])
    end
  end
end
