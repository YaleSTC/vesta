require 'rails_helper'

RSpec.describe TaggablePolicy do
  subject { described_class }
  let(:taggable) { FactoryGirl.build_stubbed(:suite) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    permissions :add_tag?, :edit_tags?, :remove_tag? do
      it { is_expected.not_to permit(user, taggable) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    permissions :add_tag?, :edit_tags?, :remove_tag? do
      it { is_expected.not_to permit(user, taggable) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    permissions :add_tag?, :edit_tags?, :remove_tag? do
      it { is_expected.to permit(user, taggable) }
    end
  end
end
