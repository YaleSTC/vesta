# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  let(:other_user) { FactoryGirl.build_stubbed(:user) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :show? do
      it { is_expected.to permit(user, user) }
      it { is_expected.to permit(user, other_user) }
    end
    permissions :edit?, :update? do
      it { is_expected.not_to permit(user, user) }
    end
    context 'draw in pre-lottery status' do
      before do
        draw = instance_spy('draw')
        allow(draw).to receive(:draft?).and_return(false)
        allow(draw).to receive(:intent_locked).and_return(false)
        allow(user).to receive(:draw).and_return(draw)
      end
      permissions :edit_intent?, :update_intent? do
        context  'user in group' do # rubocop:disable RSpec/NestedGroups
          before do
            allow(user).to receive(:group).and_return(instance_spy('group'))
          end
          it { is_expected.not_to permit(user, user) }
        end
        context  'user not in group' do # rubocop:disable RSpec/NestedGroups
          before do
            allow(user).to receive(:group).and_return(nil)
          end
          it { is_expected.to permit(user, user) }
        end
      end
    end
    context 'draw not pre-lottery status' do
      before do
        draw = instance_spy('draw')
        allow(draw).to receive(:draft?).and_return(true)
        allow(draw).to receive(:intent_locked).and_return(false)
        allow(user).to receive(:draw).and_return(draw)
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.not_to permit(user, user) }
      end
    end
    context 'draw intent locked' do
      before do
        draw = instance_spy('draw')
        allow(draw).to receive(:draft?).and_return(false)
        allow(draw).to receive(:intent_locked).and_return(true)
        allow(user).to receive(:draw).and_return(draw)
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.not_to permit(user, user) }
      end
    end
    permissions :destroy?, :update?, :edit?, :edit_intent?, :update_intent? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index?, :build?, :create?, :new? do
      it { is_expected.not_to permit(user, User) }
    end
    permissions :draw_info? do
      context 'other user is admin' do
        before { allow(other_user).to receive(:admin?).and_return(true) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is not in draw' do
        before { allow(other_user).to receive(:draw_id).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'non-admin in draw' do
        before do
          allow(other_user).to receive(:admin?).and_return(false)
          allow(other_user).to receive(:draw_id).and_return(1)
        end
        it { is_expected.to permit(user, other_user) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :show? do
      it { is_expected.to permit(user, user) }
      it { is_expected.to permit(user, other_user) }
    end
    permissions :edit?, :update? do
      it { is_expected.not_to permit(user, user) }
    end
    context 'draw in pre-lottery status' do
      before do
        draw = instance_spy('draw')
        allow(draw).to receive(:draft?).and_return(false)
        allow(draw).to receive(:intent_locked).and_return(false)
        allow(user).to receive(:draw).and_return(draw)
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.to permit(user, user) }
        it { is_expected.to permit(user, other_user) }
      end
    end
    context 'draw not pre-lottery status' do
      before do
        draw = instance_spy('draw')
        allow(draw).to receive(:draft?).and_return(true)
        allow(draw).to receive(:intent_locked).and_return(false)
        allow(user).to receive(:draw).and_return(draw)
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.to permit(user, user) }
        it { is_expected.to permit(user, other_user) }
      end
    end
    context 'draw intent locked' do
      before do
        draw = instance_spy('draw')
        allow(draw).to receive(:draft?).and_return(false)
        allow(draw).to receive(:intent_locked).and_return(true)
        allow(user).to receive(:draw).and_return(draw)
      end
      permissions :edit_intent?, :update_intent? do
        it { is_expected.to permit(user, user) }
        it { is_expected.to permit(user, other_user) }
      end
    end
    permissions :destroy?, :update?, :edit? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index?, :build?, :create?, :new? do
      it { is_expected.not_to permit(user, User) }
    end
    permissions :draw_info? do
      context 'other user is admin' do
        before { allow(other_user).to receive(:admin?).and_return(true) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is not in draw' do
        before { allow(other_user).to receive(:draw_id).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'non-admin in draw' do
        before do
          allow(other_user).to receive(:admin?).and_return(false)
          allow(other_user).to receive(:draw_id).and_return(1)
        end
        it { is_expected.to permit(user, other_user) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :show?, :destroy?, :update?, :edit?,
                :edit_intent?, :update_intent? do
      it { is_expected.to permit(user, other_user) }
    end
    permissions :index?, :build?, :create?, :new? do
      it { is_expected.to permit(user, User) }
    end
    permissions :draw_info? do
      context 'other user is admin' do
        before { allow(other_user).to receive(:admin?).and_return(true) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is not in draw' do
        before { allow(other_user).to receive(:draw_id).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'non-admin in draw' do
        before do
          allow(other_user).to receive(:admin?).and_return(false)
          allow(other_user).to receive(:draw_id).and_return(1)
        end
        it { is_expected.to permit(user, other_user) }
      end
    end
  end
end
