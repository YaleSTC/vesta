# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailExportsHelper, type: :helper do
  let(:email_export) { instance_spy('email_export') }

  describe '#draw_scope_str' do
    it 'handles unscoped cases' do
      allow(email_export).to receive(:draw_scoped?).and_return(false)
      expect(helper.draw_scope_str(email_export)).to eq('All groups')
    end
    it 'handles drawless cases' do
      allow(email_export).to receive(:draw_scoped?).and_return(true)
      allow(email_export).to receive(:draw_id).and_return(nil)
      expect(helper.draw_scope_str(email_export)).to eq('Special groups')
    end
    it 'handles scoped cases' do
      allow(email_export).to receive(:draw_scoped?).and_return(true)
      allow(email_export).to receive(:draw_id).and_return(1)
      draw = instance_spy('draw', name: 'foo')
      allow(Draw).to receive(:find).with(1).and_return(draw)
      expect(helper.draw_scope_str(email_export)).to eq('Draw: foo')
    end

    describe '#size_scope_str' do
      it 'handles scoped cases' do
        allow(email_export).to receive(:size).and_return(1)
        expect(helper.size_scope_str(email_export)).to eq(', size: 1')
      end
      it 'handles unscoped cases' do
        allow(email_export).to receive(:size).and_return(nil)
        expect(helper.size_scope_str(email_export)).to eq('')
      end
    end

    describe '#flag_scope_str' do
      it 'handles doubly scoped cases' do
        allow(email_export).to receive(:locked).and_return(true)
        allow(email_export).to receive(:leaders_only).and_return(:true)
        expect(helper.flag_scope_str(email_export))
          .to eq(' (leaders of locked groups)')
      end
      it 'handles singly scoped cases' do
        allow(email_export).to receive(:locked).and_return(true)
        allow(email_export).to receive(:leaders_only).and_return(false)
        expect(helper.flag_scope_str(email_export)).to eq(' (locked only)')
      end
      it 'handles unscoped cases' do
        allow(email_export).to receive(:locked).and_return(false)
        allow(email_export).to receive(:leaders_only).and_return(false)
        expect(helper.flag_scope_str(email_export)).to eq('')
      end
    end
  end
end
