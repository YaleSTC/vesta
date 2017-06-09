# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#with_tooltip' do
    it 'returns a valid tooltip hash for Foundation' do
      text = 'this is tooltip'
      expected = { data: { tooltip: true, 'disable-hover' => false },
                   aria: { haspopup: true }, class: 'has-tip ', title: text }
      expect(helper.with_tooltip(text: text)).to match(expected)
    end
    it 'allows for class overrides' do
      text = 'this is tooltip'
      expected = { data: { tooltip: true, 'disable-hover' => false },
                   aria: { haspopup: true }, class: 'has-tip foo', title: text }
      expect(helper.with_tooltip(text: text, class_override: 'foo')).to \
        match(expected)
    end
  end

  describe '#headerize_size' do
    it 'returns a capitalized, pluralized version of the suite string' do
      allow(helper).to receive(:size_str).with(1).and_return('single')
      expect(helper.headerize_size(1)).to eq('Singles')
    end
  end

  describe '#settings_path' do
    it 'returns a link to edit the passed college if persisted' do
      college = instance_spy('college', persisted?: true)
      expect(helper.settings_path(college)).to match(/edit/)
    end
    it 'returns a link to create a college if unpersisted' do
      college = instance_spy('college', id: nil)
      expect(helper.settings_path(college)).to match(/new/)
    end
  end

  describe '#full_title' do
    it 'returns "Vesta" by default' do
      expect(helper.full_title).to eq('Vesta')
    end
    it 'returns a customized page title if passed a string' do
      expect(helper.full_title('foo')).to eq('foo | Vesta')
    end
  end
end
