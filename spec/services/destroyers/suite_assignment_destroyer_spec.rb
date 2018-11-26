# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteAssignmentDestroyer do
  describe '#destroy' do
    context 'failure' do
      it 'checks that the group has a suite assignment' do
        group = instance_spy('group', suite_assignment: nil)
        result = described_class.new(group: group)
        expect(result).not_to be_valid
      end
      it 'returns a nil redirect_object if the destroy fails' do
        sa = instance_spy('suite_assignment', blank?: false, destroy: false)
        group = instance_spy('group', suite_assignment: sa)
        result = described_class.destroy(group: group)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns an error flash if the destroy fails' do
        sa = instance_spy('suite_assignment', blank?: false, destroy: false)
        group = instance_spy('group', suite_assignment: sa, name: 'foo')
        result = described_class.destroy(group: group)
        expect(result[:msg].keys).to eq([:error])
      end
    end
    context ' success' do
      it 'sets the object to the group' do
        sa = instance_spy('suite_assignment', blank?: false, destroy: true)
        group = instance_spy('group', suite_assignment: sa, name: 'foo')
        result = described_class.destroy(group: group)
        expect(result[:redirect_object]).to eq(group)
      end
      it "destroys group's suite assignment" do
        sa = instance_spy('suite_assignment', blank?: false, destroy: true)
        group = instance_spy('group', suite_assignment: sa, name: 'foo')
        described_class.destroy(group: group)
        expect(sa).to have_received(:destroy)
      end
      it 'sets a success message in the flash' do
        sa = instance_spy('suite_assignment', blank?: false, destroy: true)
        group = instance_spy('group', suite_assignment: sa, name: 'foo')
        result = described_class.destroy(group: group)
        expect(result[:msg].keys).to eq([:success])
      end
    end
  end
end
