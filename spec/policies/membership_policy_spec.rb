# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups, RSpec/ScatteredSetup

require 'rails_helper'

RSpec.describe MembershipPolicy do
  subject { described_class }

  let(:membership) { build_stubbed(:membership) }
  let(:group) { instance_spy('group', present?: true, blank?: false) }
  let(:draw) { instance_spy('draw', present?: true) }

  context 'student' do
    let(:user) { build_stubbed(:user, role: 'student') }

    permissions :request_to_join? do
      context 'already has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'has no group' do
        before do
          allow(user).to receive(:group).and_return(nil)
          allow(membership).to receive(:group).and_return(group)
        end

        context 'but has no draw' do
          before { allow(user).to receive(:draw).and_return(nil) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and has a draw' do
          before { allow(group).to receive(:draw).and_return(draw) }

          context 'but draws do not match' do
            let(:other_draw) { build_stubbed(:draw) }

            before { allow(user).to receive(:draw).and_return(other_draw) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and draws match' do
            before { allow(user).to receive(:draw).and_return(draw) }

            context 'but draw is not pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and draw is pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :new_invite?, :create_invite? do
      context 'not the leader of the group' do
        before do
          allow(membership).to receive(:group).and_return(group)
          allow(user).to receive(:leader_of?).with(group).and_return(false)
        end

        it { is_expected.not_to permit(user, membership) }
      end

      context 'and is the leader of the group' do
        before do
          allow(membership).to receive(:group).and_return(group)
          allow(user).to receive(:leader_of?).with(group).and_return(true)
        end

        context 'but the group is not open' do
          before { allow(group).to receive(:open?).and_return(false) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the group is open' do
          before { allow(group).to receive(:open?).and_return(true) }

          it { is_expected.to permit(user, membership) }
        end
      end
    end

    permissions :accept? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'the group is not open' do
        before { allow(group).to receive(:open?).and_return(false) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before { allow(group).to receive(:open?).and_return(true) }

        context 'but the record is already accepted' do
          before { allow(membership).to receive(:accepted?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the record is not accepted' do
          before { allow(membership).to receive(:accepted?).and_return(false) }

          context "the user's membership" do
            before { allow(membership).to receive(:user).and_return(user) }

            context 'but it is the leader of the group' do
              before { allow(user).to receive(:leader_of?).and_return(true) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and it is not the leader of the group' do
              before { allow(user).to receive(:leader_of?).and_return(false) }

              it { is_expected.to permit(user, membership) }
            end
          end

          context "not the user's membership" do
            before do
              other_user = instance_spy('User')
              allow(membership).to receive(:user).and_return(other_user)
            end

            context 'but it is not the leader of the group' do
              before { allow(user).to receive(:leader_of?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and it is the leader of the group' do
              before { allow(user).to receive(:leader_of?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :destroy? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'the membership is locked' do
        before { allow(membership).to receive(:locked?).and_return(true) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the membership is not locked' do
        before { allow(membership).to receive(:locked?).and_return(false) }

        context "the user's membership" do
          before { allow(membership).to receive(:user).and_return(user) }

          context 'but it is the leader of the group' do
            before { allow(user).to receive(:leader_of?).and_return(true) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and it is not the leader of the group' do
            before { allow(user).to receive(:leader_of?).and_return(false) }

            it { is_expected.to permit(user, membership) }
          end
        end

        context "not the user's membership" do
          before do
            other_user = instance_spy('User')
            allow(membership).to receive(:user).and_return(other_user)
          end

          context 'but it is not the leader of the group' do
            before { allow(user).to receive(:leader_of?).and_return(false) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and it is the leader of the group' do
            before { allow(user).to receive(:leader_of?).and_return(true) }

            context 'but the membership is already accepted' do
              before do
                allow(membership).to receive(:accepted?).and_return(true)
              end

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and the membership is not accepted' do
              before do
                allow(membership).to receive(:accepted?).and_return(false)
              end

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :finalize? do
      context "the user's membership" do
        before { allow(membership).to receive(:user).and_return(user) }

        context 'but it is the leader of the group' do
          before { allow(user).to receive(:leader_of?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and it is not the leader of the group' do
          before { allow(user).to receive(:leader_of?).and_return(false) }

          context 'but the membership is already locked' do
            before { allow(membership).to receive(:locked?).and_return(true) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the membership is not locked' do
            before do
              allow(membership).to receive(:locked?).and_return(false)
              allow(membership).to receive(:group).and_return(group)
            end

            context 'but the group is not finalizing' do
              before { allow(group).to receive(:finalizing?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and the group is finalizing' do
              before { allow(group).to receive(:finalizing?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end
  end

  context 'rep' do
    let(:user) { build_stubbed(:user, role: 'rep') }

    permissions :request_to_join? do
      context 'already has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'has no group' do
        before do
          allow(user).to receive(:group).and_return(nil)
          allow(membership).to receive(:group).and_return(group)
        end

        context 'but has no draw' do
          before { allow(user).to receive(:draw).and_return(nil) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and has a draw' do
          before { allow(user).to receive(:draw).and_return(draw) }

          context 'but draws do not match' do
            let(:other_draw) { build_stubbed(:draw) }

            before { allow(group).to receive(:draw).and_return(other_draw) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and draws match' do
            before { allow(group).to receive(:draw).and_return(draw) }

            context 'but draw is not pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and draw is pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :new_invite?, :create_invite? do
      context 'the group is not open' do
        before do
          allow(group).to receive(:open?).and_return(false)
          allow(membership).to receive(:group).and_return(group)
        end

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before do
          allow(group).to receive(:open?).and_return(true)
          allow(membership).to receive(:group).and_return(group)
        end

        it { is_expected.to permit(user, membership) }
      end
    end

    permissions :destroy? do
      context 'the membership is locked' do
        before { allow(membership).to receive(:locked?).and_return(true) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the membership is not locked' do
        before { allow(membership).to receive(:locked?).and_return(false) }

        it { is_expected.to permit(user, membership) }
      end
    end

    permissions :accept? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'the group is not open' do
        before { allow(group).to receive(:open?).and_return(false) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before { allow(group).to receive(:open?).and_return(true) }

        context 'but the record is already accepted' do
          before { allow(membership).to receive(:accepted?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the record is not accepted' do
          before { allow(membership).to receive(:accepted?).and_return(false) }

          it { is_expected.to permit(user, membership) }
        end
      end
    end

    permissions :finalize? do
      context "the user's membership" do
        before { allow(membership).to receive(:user).and_return(user) }

        context 'but it is the leader of the group' do
          before { allow(user).to receive(:leader_of?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and it is not the leader of the group' do
          before { allow(user).to receive(:leader_of?).and_return(false) }

          context 'but the membership is already locked' do
            before { allow(membership).to receive(:locked?).and_return(true) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the membership is not locked' do
            before do
              allow(membership).to receive(:locked?).and_return(false)
              allow(membership).to receive(:group).and_return(group)
            end

            context 'but the group is not finalizing' do
              before { allow(group).to receive(:finalizing?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and the group is finalizing' do
              before { allow(group).to receive(:finalizing?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end
  end

  context 'admin' do
    let(:user) { build_stubbed(:user, role: 'admin', draw: nil) }

    permissions :request_to_join?, :finalize? do
      it { is_expected.not_to permit(user, membership) }
    end

    permissions :new_invite?, :create_invite? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'the group is not open' do
        before { allow(group).to receive(:open?).and_return(false) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before { allow(group).to receive(:open?).and_return(true) }

        it { is_expected.to permit(user, membership) }
      end
    end

    permissions :destroy? do
      context 'the membership is locked' do
        before { allow(membership).to receive(:locked?).and_return(true) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the membership is not locked' do
        before { allow(membership).to receive(:locked?).and_return(false) }

        it { is_expected.to permit(user, membership) }
      end
    end

    permissions :accept? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'the group is not open' do
        before { allow(group).to receive(:open?).and_return(false) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before { allow(group).to receive(:open?).and_return(true) }

        context 'but the record is already accepted' do
          before { allow(membership).to receive(:accepted?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the record is not accepted' do
          before { allow(membership).to receive(:accepted?).and_return(false) }

          it { is_expected.to permit(user, membership) }
        end
      end
    end
  end
end
