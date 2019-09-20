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

  describe '#status_string' do
    let(:group) { create(:group) }
    let(:suite) { create(:suite, group: group) }

    it 'returns available if the suite is available' do
      user = build_stubbed(:user)
      setup_suite(suite, nil, false)
      expect(helper.status_string(suite, user)).to eq('Available')
    end

    it 'returns unavailable with suite\'s assignment if group is not medical' do
      user = build_stubbed(:user)
      setup_suite(suite, group, false)
      expected = "Unavailable (Assigned to #{suite.group.name})"
      expect(strip_tags(helper.status_string(suite, user))).to eq(expected)
    end

    it 'returns unavailable with suite\'s assignment if group is medical' do
      user = build_stubbed(:user, role: 'admin')
      setup_suite(suite, group, true)
      expected = "Unavailable (Assigned to #{suite.group.name})"
      expect(strip_tags(helper.status_string(suite, user))).to eq(expected)
    end

    it 'returns unavailable if group is medical and user is not admin' do
      user = build_stubbed(:user)
      setup_suite(suite, group, true)
      expect(helper.status_string(suite, user)).to eq('Unavailable')
    end

    def setup_suite(suite, group, medical)
      suite.group = group
      suite.medical = medical
    end
  end
end
