# frozen_string_literal: true
require 'rails_helper'

describe Generator do
  OBJECTS = [User, Room, Suite, Building, Draw].freeze

  shared_examples 'generates a valid' do |klass|
    it klass.to_s do
      expect { described_class.generate(model: klass.to_s) }.to \
        change { klass.count }.by(1)
    end
  end

  OBJECTS.each { |o| it_behaves_like 'generates a valid', o }

  it 'can generate an admin' do
    expect { described_class.generate_admin }.to \
      change { User.admin.count }.by(1)
  end
end
