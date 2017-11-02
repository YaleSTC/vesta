# frozen_string_literal: true

require 'rails_helper'
require 'simple_form'

RSpec.describe UsersHelper, type: :helper do
  describe '#profile_field' do
    it 'returns an enabled field if the attribute is missing' do
      u = FactoryGirl.build_stubbed(:user, first_name: nil, id: 123)
      helper.simple_form_for u do |f|
        expect(helper.profile_field(form: f, user: u, field: :first_name)).to \
          eq(f.input(:first_name, disabled: false))
      end
    end
    it 'returns an enabled field if the attribute is empty' do
      u = FactoryGirl.build_stubbed(:user, first_name: '', id: 123)
      helper.simple_form_for u do |f|
        expect(helper.profile_field(form: f, user: u, field: :first_name)).to \
          eq(f.input(:first_name, disabled: false))
      end
    end
    # rubocop:disable RSpec/ExampleLength
    it 'returns a disabled and a hidden field if the attribute is populated' do
      u = FactoryGirl.build_stubbed(:user, first_name: 'John', id: 123)
      helper.simple_form_for u do |f|
        expect(helper.profile_field(form: f, user: u, field: :first_name)).to \
          eq(f.input(:first_name, disabled: true) + "\n" +
             f.input(:first_name, as: :hidden))
      end
    end
    it 'returns a disabled and a hidden field if the attribute is an integer' do
      u = FactoryGirl.build_stubbed(:user, class_year: 2018, id: 123)
      helper.simple_form_for u do |f|
        expect(helper.profile_field(form: f, user: u, field: :class_year)).to \
          eq(f.input(:class_year, disabled: true) + "\n" +
             f.input(:class_year, as: :hidden))
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
