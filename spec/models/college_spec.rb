# frozen_string_literal: true
require 'rails_helper'

RSpec.describe College do
  describe 'validations' do
    subject { FactoryGirl.build(:college) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:admin_email) }
    it { is_expected.to validate_presence_of(:dean) }
    it { is_expected.to validate_presence_of(:site_url) }
  end
end
