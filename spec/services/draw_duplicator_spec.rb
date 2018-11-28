# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawDuplicator do
  describe 'on success' do
    let(:draw) { create(:draw_in_lottery) }
    let(:new_draw_name) { draw.name + '-copy' }
    let(:suites) { draw.suites }

    it 'creates a new draw' do
      described_class.duplicate(draw: draw)
      expect(Draw.where(name: new_draw_name)).to exist
    end

    it 'copies suites' do
      described_class.duplicate(draw: draw)
      new_draw = Draw.find_by(name: new_draw_name)
      expect(new_draw.suites).to match_array(suites)
    end

    it 'persists when original draw removed' do
      described_class.duplicate(draw: draw)
      new_draw = Draw.find_by(name: new_draw_name)
      Destroyer.destroy(object: draw, name_method: :name)
      expect(new_draw.suites).to match_array(suites)
    end

    it 'returns error if copy exists' do
      described_class.duplicate(draw: draw)
      result = described_class.duplicate(draw: draw)
      msg = 'A copy of this draw already exists'
      expect(result[:msg][:error]).to include(msg)
    end
  end
end
