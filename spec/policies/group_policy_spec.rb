# frozen_string_literal: true

# rubocop:disable RSpec/ScatteredSetup, RSpec/RepeatedExample
# rubocop:disable RSpec/NestedGroups

require 'rails_helper'

RSpec.describe GroupPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    let(:group) { FactoryGirl.build_stubbed(:group, leader: user) }
    let(:other_group) { FactoryGirl.build_stubbed(:group) }

    permissions :create? do
      context 'in pre_lottery draw, not in group, on_campus' do
        before do
          draw = instance_spy('draw', pre_lottery?: true)
          allow(user).to receive(:draw).and_return(draw)
          allow(user).to receive(:group).and_return(nil)
          allow(user).to receive(:on_campus?).and_return(true)
        end
        it { is_expected.to permit(user, Group) }
      end
      context 'in pre_lottery draw, in group, on_campus' do
        before do
          draw = instance_spy('draw', pre_lottery?: true)
          allow(user).to receive(:draw).and_return(draw)
          allow(user).to receive(:group).and_return(instance_spy('group'))
          allow(user).to receive(:on_campus?).and_return(true)
        end
        it { is_expected.not_to permit(user, Group) }
      end
      context 'in pre_lottery draw, not in group, not on_campus' do
        before do
          draw = instance_spy('draw', pre_lottery?: true)
          allow(user).to receive(:draw).and_return(draw)
          allow(user).to receive(:group).and_return(nil)
          allow(user).to receive(:on_campus?).and_return(false)
        end
        it { is_expected.not_to permit(user, Group) }
      end
      context 'in non-pre_lottery' do
        before do
          draw = instance_spy('draw', pre_lottery?: false)
          allow(user).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, Group) }
      end
      context 'not in draw' do
        before { allow(user).to receive(:draw).and_return(nil) }
        it { is_expected.not_to permit(user, Group) }
      end
    end
    permissions :accept_invitation? do
      context 'invited, not in group' do
        before do
          allow(other_group).to receive(:invitations).and_return([user])
          allow(user).to receive(:group).and_return(nil)
        end
        it { is_expected.to permit(user, other_group) }
      end
      context 'in same draw, in group' do
        before do
          allow(user).to receive(:group).and_return(group)
          allow(other_group).to receive(:invitations).and_return([user])
        end
        it { is_expected.not_to permit(user, other_group) }
      end
    end
    permissions :leave? do
      context 'in group, not leader' do
        before do
          allow(other_group).to receive(:members).and_return([user])
          allow(other_group).to receive(:leader)
            .and_return(instance_spy('user'))
        end
        it { is_expected.to permit(user, other_group) }
      end
      context 'in locked_group, not leader' do
        before do
          allow(other_group).to receive(:members).and_return([user])
          allow(other_group).to receive(:locked?).and_return(true)
        end
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'in group, leader' do
        before { allow(group).to receive(:members).and_return([user]) }
        it { is_expected.not_to permit(user, group) }
      end
      context 'not in group' do
        before { allow(other_group).to receive(:members).and_return([]) }
        it { is_expected.not_to permit(user, other_group) }
      end
    end
    permissions :index? do
      it { is_expected.not_to permit(user, Group) }
    end
    permissions :show? do
      it { is_expected.to permit(user, group) }
      it { is_expected.to permit(user, other_group) }
    end
    permissions :destroy?, :edit?, :update?, :accept_request?, :change_leader?,
                :view_pending_members?, :reject_pending? do
      context 'not finalizing or locked' do
        before do
          allow(group).to receive(:finalizing?).and_return(false)
          allow(group).to receive(:locked?).and_return(false)
        end
        it { is_expected.to permit(user, group) }
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'finalizing' do
        before do
          allow(group).to receive(:finalizing?).and_return(true)
          allow(group).to receive(:locked?).and_return(false)
        end
        it { is_expected.not_to permit(user, group) }
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'locked' do
        before do
          allow(group).to receive(:finalizing?).and_return(false)
          allow(group).to receive(:locked?).and_return(true)
        end
        it { is_expected.not_to permit(user, group) }
        it { is_expected.not_to permit(user, other_group) }
      end
    end
    permissions :send_invites?, :invite? do
      context 'group open' do
        before { allow(group).to receive(:open?).and_return(true) }
        it { is_expected.to permit(user, group) }
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'group not open' do
        before { allow(group).to receive(:open?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
        it { is_expected.not_to permit(user, other_group) }
      end
    end
    permissions :request_to_join? do
      context 'in same draw as record, not in group, draw is pre_lottery' do
        before do
          draw = instance_spy('Draw', pre_lottery?: true)
          allow(group).to receive(:draw).and_return(draw)
          allow(user).to receive(:draw).and_return(draw)
          allow(user).to receive(:group).and_return(nil)
        end
        it { is_expected.to permit(user, group) }
      end
      context 'in same draw as record, not in group, draw is not pre_lottery' do
        before do
          draw = instance_spy('Draw', pre_lottery?: false)
          allow(group).to receive(:draw).and_return(draw)
          allow(user).to receive(:draw).and_return(draw)
          allow(user).to receive(:group).and_return(nil)
        end
        it { is_expected.not_to permit(user, group) }
      end
      context 'in different draw, not in group' do
        before do
          allow(group).to receive(:draw).and_return(instance_spy('Draw'))
          allow(user).to receive(:draw).and_return(instance_spy('Draw'))
          allow(user).to receive(:group).and_return(nil)
        end
        it { is_expected.not_to permit(user, group) }
      end
      context 'in same draw, in group' do
        before do
          draw = instance_spy('Draw')
          allow(group).to receive(:draw).and_return(draw)
          allow(user).to receive(:draw).and_return(draw)
          allow(user).to receive(:group).and_return(instance_spy('Group'))
        end
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :finalize_membership? do
      context 'in finalizing group, accepted membership' do
        before do
          allow(user).to receive(:group).and_return(other_group)
          allow(other_group).to receive(:finalizing?).and_return(true)
        end
        it { is_expected.to permit(user, other_group) }
      end
      context 'in finalizing group, pending membership' do
        before do
          allow(user).to receive(:group).and_return(nil)
          allow(other_group).to receive(:finalizing?).and_return(true)
        end
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'in full group, accepted membership' do
        before do
          allow(user).to receive(:group).and_return(other_group)
          allow(other_group).to receive(:finalizing?).and_return(false)
        end
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'already locked membership' do
        before do
          allow(user).to receive(:group).and_return(other_group)
          allow(other_group).to receive(:finalizing?).and_return(true)
          allow(other_group).to receive(:locked_members).and_return([user])
        end
        it { is_expected.not_to permit(user, other_group) }
      end
    end
    permissions :finalize? do
      context 'group is not full' do
        before { allow(group).to receive(:full?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end

      context 'group is full' do
        before { allow(group).to receive(:full?).and_return(true) }

        context 'group is already finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(true) }
          it { is_expected.not_to permit(user, group) }
        end

        context 'group is not finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(false) }

          context 'group is already locked' do
            before { allow(group).to receive(:locked?).and_return(true) }
            it { is_expected.not_to permit(user, group) }
          end
          context 'and group is not locked' do
            before { allow(group).to receive(:locked?).and_return(false) }
            it { is_expected.to permit(user, group) }
          end
        end
      end
    end
    permissions :assign_rooms? do
      before do
        suite = instance_spy('suite', present?: true)
        allow(group).to receive(:suite).and_return(suite)
        allow(user).to receive(:group).and_return(group)
        allow(user).to receive(:room_id).and_return(nil)
      end
      it { is_expected.to permit(user, group) }
      it { is_expected.not_to permit(user, other_group) }
    end
    permissions :lock?, :unlock?, :advanced_edit?, :make_drawless?,
                :edit_room_assignment? do
      it { is_expected.not_to permit(user, other_group) }
      it { is_expected.not_to permit(user, group) }
    end

    permissions :select_suite?, :assign_suite? do
      context 'next group, group leader' do
        before do
          draw = instance_spy('Draw', student_selection?: true)
          allow(draw).to receive(:next_group?).with(group).and_return(true)
          allow(group).to receive(:draw).and_return(draw)
        end
        it { is_expected.to permit(user, group) }
      end
      context 'group leader, not next group' do
        before do
          draw = instance_spy('Draw', student_selection?: true)
          allow(draw).to receive(:next_group?).with(group).and_return(false)
          allow(group).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, group) }
      end
      context 'next group, not leader' do
        before do
          draw = instance_spy('Draw', student_selection?: true)
          allow(draw).to receive(:next_group?).with(other_group)
                                              .and_return(true)
          allow(other_group).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, other_group) }
      end
      context 'admin selection mode' do
        before do
          draw = instance_spy('Draw', student_selection?: false)
          allow(draw).to receive(:next_group?).with(group).and_return(true)
          allow(group).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, group) }
      end
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    let(:group) do
      FactoryGirl.build_stubbed(:group,
                                draw: FactoryGirl.build_stubbed(:draw))
    end

    permissions :create? do
      it { is_expected.to permit(user, Group) }
    end
    permissions :index? do
      it { is_expected.to permit(user, Group) }
    end
    permissions :show?, :edit?, :update?, :destroy?, :accept_request?,
                :advanced_edit?, :view_pending_members?, :reject_pending?,
                :change_leader?, :select_suite?, :assign_suite? do
      it { is_expected.to permit(user, group) }
    end
    permissions :make_drawless? do
      it { is_expected.not_to permit(user, group) }
    end
    permissions :send_invites?, :invite? do
      context 'group open' do
        before { allow(group).to receive(:open?).and_return(true) }
        it { is_expected.to permit(user, group) }
      end
      context 'group not open' do
        before { allow(group).to receive(:open?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :lock? do
      context 'lockable group' do
        before do
          allow(group).to receive(:open?).and_return(false)
          allow(group).to receive(:locked?).and_return(false)
        end
        it { is_expected.to permit(user, group) }
      end
      context 'open group' do
        before { allow(group).to receive(:open?).and_return(true) }
        it { is_expected.not_to permit(user, group) }
      end
      context 'locked group' do
        before { allow(group).to receive(:locked?).and_return(true) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :unlock? do
      context 'unlockable group' do
        before { allow(group).to receive(:unlockable?).and_return(true) }
        it { is_expected.to permit(user, group) }
      end
      context 'not unlockable group' do
        before { allow(group).to receive(:unlockable?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :request_to_join?, :finalize_membership? do
      it { is_expected.not_to permit(user, group) }
    end
    permissions :finalize? do
      context 'group is not full' do
        before { allow(group).to receive(:full?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end

      context 'group is full' do
        before { allow(group).to receive(:full?).and_return(true) }

        context 'group is already finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(true) }
          it { is_expected.not_to permit(user, group) }
        end

        context 'group is not finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(false) }

          context 'group is already locked' do
            before { allow(group).to receive(:locked?).and_return(true) }
            it { is_expected.not_to permit(user, group) }
          end
          context 'and group is not locked' do
            before { allow(group).to receive(:locked?).and_return(false) }
            it { is_expected.to permit(user, group) }
          end
        end
      end
    end
    permissions :assign_rooms? do
      before do
        suite = instance_spy('suite', present?: true)
        allow(group).to receive(:suite).and_return(suite)
        leader = instance_spy('user', room_id: nil)
        allow(group).to receive(:leader).and_return(leader)
      end
      it { is_expected.to permit(user, group) }
    end
    permissions :edit_room_assignment? do
      before do
        leader = instance_spy('user', room_id: 123)
        allow(group).to receive(:leader).and_return(leader)
      end
      it { is_expected.not_to permit(user, group) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    let(:group) do
      FactoryGirl.build_stubbed(:group,
                                draw: FactoryGirl.build_stubbed(:draw))
    end

    permissions :create? do
      it { is_expected.to permit(user, Group) }
    end
    permissions :index? do
      it { is_expected.to permit(user, [group]) }
    end
    permissions :show?, :edit?, :update?, :destroy?, :accept_request?,
                :advanced_edit?, :view_pending_members?, :reject_pending?,
                :change_leader?, :make_drawless?, :select_suite?,
                :assign_suite? do
      it { is_expected.to permit(user, group) }
    end
    permissions :send_invites?, :invite? do
      context 'group open' do
        before { allow(group).to receive(:open?).and_return(true) }
        it { is_expected.to permit(user, group) }
      end
      context 'group not open' do
        before { allow(group).to receive(:open?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :lock? do
      context 'lockable group' do
        before do
          allow(group).to receive(:open?).and_return(false)
          allow(group).to receive(:locked?).and_return(false)
        end
        it { is_expected.to permit(user, group) }
      end
      context 'open group' do
        before { allow(group).to receive(:open?).and_return(true) }
        it { is_expected.not_to permit(user, group) }
      end
      context 'locked group' do
        before { allow(group).to receive(:locked?).and_return(true) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :unlock? do
      context 'unlockable group' do
        before { allow(group).to receive(:unlockable?).and_return(true) }
        it { is_expected.to permit(user, group) }
      end
      context 'not unlockable group' do
        before { allow(group).to receive(:unlockable?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end
    end
    permissions :request_to_join?, :finalize_membership? do
      it { is_expected.not_to permit(user, group) }
    end
    permissions :finalize? do
      context 'group is not full' do
        before { allow(group).to receive(:full?).and_return(false) }
        it { is_expected.not_to permit(user, group) }
      end

      context 'group is full' do
        before { allow(group).to receive(:full?).and_return(true) }

        context 'group is already finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(true) }
          it { is_expected.not_to permit(user, group) }
        end

        context 'group is not finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(false) }

          context 'group is already locked' do
            before { allow(group).to receive(:locked?).and_return(true) }
            it { is_expected.not_to permit(user, group) }
          end
          context 'and group is not locked' do
            before { allow(group).to receive(:locked?).and_return(false) }
            it { is_expected.to permit(user, group) }
          end
        end
      end
    end
    permissions :assign_rooms? do
      before do
        suite = instance_spy('suite', present?: true)
        allow(group).to receive(:suite).and_return(suite)
        leader = instance_spy('user', room_id: nil)
        allow(group).to receive(:leader).and_return(leader)
      end
      it { is_expected.to permit(user, group) }
    end
    permissions :edit_room_assignment? do
      before do
        leader = instance_spy('user', room_id: 123)
        allow(group).to receive(:leader).and_return(leader)
      end
      it { is_expected.to permit(user, group) }
    end
  end
end
