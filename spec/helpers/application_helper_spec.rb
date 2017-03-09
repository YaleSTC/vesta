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
end
