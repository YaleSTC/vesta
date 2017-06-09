# frozen_string_literal: true

require 'spec_helper'
include EnvironmentHelper

describe EnvironmentHelper do
  FALSEY_VALUES = [0, '0', false, 'false', nil, ''].freeze

  describe '.env?' do
    FALSEY_VALUES.each do |val|
      it "returns false if the variable is set to #{val}" do
        set_env('VAR', val)
        expect(env?('VAR')).to be_falsey
      end
    end

    it 'returns true if the variable is set to any other value' do
      set_env('VAR', 'foo')
      expect(env?('VAR')).to be_truthy
    end
  end

  describe '.env' do
    FALSEY_VALUES.each do |val|
      it "returns nil if the variable is set to #{val}" do
        set_env('VAR', val)
        expect(env('VAR')).to be_nil
      end
    end

    it 'returns the variable if it is set to any other value' do
      set_env('VAR', 'foo')
      expect(env('VAR')).to eq('foo')
    end
  end

  def set_env(variable, value)
    allow(ENV).to receive(:[]).with(variable).and_return(value)
  end
end
