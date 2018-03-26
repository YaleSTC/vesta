# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
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

    permissions :edit_intent?, :update_intent? do
      context 'user is not in a draw' do
        before { allow(user).to receive(:draw).and_return(nil) }
        it { is_expected.not_to permit(user, user) }
      end

      context 'user is in a draw' do
        let(:draw) { instance_spy('draw') }

        before { allow(user).to receive(:draw).and_return(draw) }

        context 'draw is not pre-lottery' do
          before { allow(draw).to receive(:pre_lottery?).and_return(false) }
          it { is_expected.not_to permit(user, user) }
        end

        context 'draw is pre-lottery' do
          let(:group) { instance_spy('group', present?: true) }

          before { allow(draw).to receive(:pre_lottery?).and_return(true) }

          context 'user has a group' do
            before { allow(user).to receive(:group).and_return(group) }
            it { is_expected.not_to permit(user, user) }
          end

          context 'user does not have a group' do
            before { allow(user).to receive(:group).and_return(nil) }

            context 'draw intent is locked' do
              before { allow(draw).to receive(:intent_locked).and_return(true) }
              it { is_expected.not_to permit(user, user) }
            end

            context 'draw intent is not locked' do
              before do
                allow(draw).to receive(:intent_locked).and_return(false)
              end

              context 'user is not current_user' do
                it { is_expected.not_to permit(user, other_user) }
              end
              context 'user is current_user' do
                it { is_expected.to permit(user, user) }
              end
            end
          end
        end
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
    permissions :destroy?, :update?, :edit? do
      it { is_expected.not_to permit(user, other_user) }
    end
    permissions :index?, :build?, :create?, :new? do
      it { is_expected.not_to permit(user, User) }
    end
    permissions :edit_intent?, :update_intent? do
      context 'other user is not in a draw' do
        before { allow(other_user).to receive(:draw).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end

      context 'other user is in a draw' do
        let(:draw) { instance_spy('draw') }

        before { allow(other_user).to receive(:draw).and_return(draw) }

        context 'draw is not pre-lottery' do
          before { allow(draw).to receive(:pre_lottery?).and_return(false) }
          it { is_expected.not_to permit(user, other_user) }
        end

        context 'draw is pre-lottery' do
          let(:group) { instance_spy('group', present?: true) }

          before { allow(draw).to receive(:pre_lottery?).and_return(true) }

          context 'other user has a group' do
            before { allow(other_user).to receive(:group).and_return(group) }
            it { is_expected.not_to permit(user, other_user) }
          end

          context 'other user does not have a group' do
            before { allow(other_user).to receive(:group).and_return(nil) }

            context 'draw intent is locked' do
              before { allow(draw).to receive(:intent_locked).and_return(true) }
              it { is_expected.not_to permit(user, other_user) }
            end

            context 'draw intent is not locked' do
              before do
                allow(draw).to receive(:intent_locked).and_return(false)
              end
              it { is_expected.to permit(user, other_user) }
            end
          end
        end
      end

      context 'user is not in a draw' do
        before { allow(user).to receive(:draw).and_return(nil) }
        it { is_expected.not_to permit(user, user) }
      end

      context 'user is in a draw' do
        let(:draw) { instance_spy('draw') }

        before { allow(user).to receive(:draw).and_return(draw) }

        context 'draw is not pre-lottery' do
          before { allow(draw).to receive(:pre_lottery?).and_return(false) }
          it { is_expected.not_to permit(user, user) }
        end

        context 'draw is pre-lottery' do
          let(:group) { instance_spy('group', present?: true) }

          before { allow(draw).to receive(:pre_lottery?).and_return(true) }

          context 'user has a group' do
            before { allow(user).to receive(:group).and_return(group) }
            it { is_expected.not_to permit(user, user) }
          end

          context 'user does not have a group' do
            before { allow(user).to receive(:group).and_return(nil) }

            context 'draw intent is locked' do
              before { allow(draw).to receive(:intent_locked).and_return(true) }
              it { is_expected.not_to permit(user, user) }
            end

            context 'draw intent is not locked' do
              before do
                allow(draw).to receive(:intent_locked).and_return(false)
              end
              context 'user is not current_user' do
                it { is_expected.not_to permit(user, other_user) }
              end
              context 'user is current_user' do
                it { is_expected.to permit(user, user) }
              end
            end
          end
        end
      end
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

    permissions :show?, :destroy?, :update?, :edit? do
      it { is_expected.to permit(user, other_user) }
    end
    permissions :index?, :build?, :create?, :new? do
      it { is_expected.to permit(user, User) }
    end

    permissions :edit_intent?, :update_intent? do
      context 'other user is not in a draw' do
        before { allow(other_user).to receive(:draw).and_return(nil) }
        it { is_expected.not_to permit(user, other_user) }
      end
      context 'other user is in a draw' do
        let(:draw) { instance_spy('draw') }

        before { allow(other_user).to receive(:draw).and_return(draw) }

        context 'draw is not before lottery' do
          before { allow(draw).to receive(:before_lottery?).and_return(false) }
          it { is_expected.not_to permit(user, other_user) }
        end

        context 'draw is before lottery' do
          let(:group) { instance_spy('group', present?: true) }

          before { allow(draw).to receive(:before_lottery?).and_return(true) }

          context 'other user has a group' do
            before { allow(other_user).to receive(:group).and_return(group) }
            it { is_expected.not_to permit(user, other_user) }
          end
          context 'other user does not have a group' do
            before { allow(other_user).to receive(:group).and_return(nil) }
            it { is_expected.to permit(user, other_user) }
          end
        end
      end
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
