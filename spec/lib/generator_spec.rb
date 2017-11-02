# frozen_string_literal: true

require 'rails_helper'

describe Generator do
  OBJECTS = [User, Room, Suite, Building, Draw, College].freeze

  shared_examples 'generates a valid' do |klass|
    it klass.to_s do
      expect { described_class.generate(model: klass.to_s) }.to \
        change { klass.count }.by(1)
    end
  end

  OBJECTS.each { |o| it_behaves_like 'generates a valid', o }

  it 'can generate an superuser' do
    expect { described_class.generate_superuser }.to \
      change { User.superuser.count }.by(1)
  end

  it 'fails if a record is not persisted after 50 tries' do
    allow(UserGenerator).to receive(:generate).and_return(nil)
    expect { described_class.generate(model: 'user') }.to \
      raise_exception(RuntimeError)
  end
end
