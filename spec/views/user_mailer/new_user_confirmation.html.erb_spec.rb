# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'user_mailer/new_user_confirmation.html.erb' do
  before { mock_assigns }
  context 'with password set' do
    before { assign(:password, 'foo') }

    it 'displays information about the password' do
      render
      expect(rendered).to match(/password/)
    end
    it 'does not display CAS info' do
      render
      expect(rendered).not_to match(/CAS/)
    end
  end

  context 'with no password set' do
    before { assign(:password, nil) }

    it 'displays information about CAS' do
      render
      expect(rendered).to match(/CAS/)
    end
    it 'does not display password info' do
      render
      expect(rendered).not_to match(/password/)
    end
  end

  def mock_assigns
    assign(:user, FactoryGirl.build_stubbed(:user))
    assign(:res_college, FactoryGirl.build_stubbed(:college))
  end
end
