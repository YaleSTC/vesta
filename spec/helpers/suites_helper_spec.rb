# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuitesHelper, type: :helper do
  describe '#medical_btn_str' do
    it 'returns "Make medical suite" if not a medical suite' do
      suite = instance_spy('suite', medical: false)
      expect(helper.medical_btn_str(suite)).to eq('Make medical suite')
    end
    it 'returns "Make non-medical suite" if a medical suite' do
      suite = instance_spy('suite', medical: true)
      expect(helper.medical_btn_str(suite)).to eq('Make non-medical suite')
    end
  end

  describe '#medical_str' do
    it 'returns "Medical suite" if medical is true' do
      expect(helper.medical_str(true)).to eq('medical suite')
    end
    it 'retusn "Non-medical suite" if medical is false' do
      expect(helper.medical_str(false)).to eq('non-medical suite')
    end
  end
end
