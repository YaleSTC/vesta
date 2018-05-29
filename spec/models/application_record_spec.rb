# frozen_string_literal: true

require 'rails_helper'

class FakeModel < ApplicationRecord
  self.table_name = 'users'

  before_validation :test_abort

  def test_abort
    handle_abort('Test error message')
  end
end

RSpec.describe ApplicationRecord, type: :model do
  context 'handles errors' do
    it 'adds error to base' do
      obj = FakeModel.new
      obj.valid?
      expect(obj.errors[:base]).to include('Test error message')
    end
  end
end
