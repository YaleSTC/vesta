# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawSizeLockToggler do
  describe '#toggle' do
    let(:draw) { FactoryGirl.create(:draw_with_members) }

    context 'success' do
      it 'locks the size when unlocked' do
        expect { described_class.toggle(draw: draw, size: '1') }.to \
          change { draw.size_locked?(1) }
      end
      it 'unlocks the size when locked' do
        draw.update(locked_sizes: [1])
        expect { described_class.toggle(draw: draw, size: '1') }.to \
          change { draw.size_locked?(1) }
      end
      it 'sets :redirect_object to nil' do
        result = described_class.toggle(draw: draw, size: '1')
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets a success flash message' do
        result = described_class.toggle(draw: draw, size: '1')
        expect(result[:msg].keys).to eq([:success])
      end
    end

    context 'failure' do
      it 'ensures that an integer is passed' do
        expect { described_class.toggle(draw: draw, size: 'a') }.not_to \
          change { draw.locked_sizes }
      end
      it 'sets :redirect_object to nil' do
        result = described_class.toggle(draw: draw, size: 'a')
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets an error flash message' do
        result = described_class.toggle(draw: draw, size: 'a')
        expect(result[:msg].keys).to eq([:error])
      end
    end
  end
end
