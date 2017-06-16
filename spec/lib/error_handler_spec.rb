# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorHandler do
  describe '.format' do
    context 'errors on a record' do
      it 'formats the messages' do
        msgs = %w(first second)
        errors = instance_spy('ActiveModel::Errors', full_messages: msgs)
        record = instance_spy('Draw', errors: errors)
        obj = instance_spy('ActiveRecord::RecordInvalid', record: record)
        expect(described_class.format(error_object: obj)).to eq(msgs.join(', '))
      end
    end
    context 'errors on the passed object' do
      it 'formats the messages' do
        msgs = %w(first second)
        errors = instance_spy('ActiveModel::Errors', full_messages: msgs)
        obj = instance_spy('SuiteAssignment', errors: errors)
        expect(described_class.format(error_object: obj)).to eq(msgs.join(', '))
      end
    end
  end
end
