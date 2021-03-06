# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
require 'rails_helper'

RSpec.describe ClipMembershipPolicy do
  subject { described_class }

  let(:record) { build_stubbed(:clip_membership) }
  let(:draw) { instance_spy('Draw', group_formation?: true) }
  let(:group) { instance_spy('Group', present?: true, draw: draw) }

  context 'student' do
    let(:user) { build_stubbed(:user, role: 'student') }

    permissions :update?, :destroy? do
      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
          end
          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the draw is not group-formation' do
              before do
                allow(draw).to receive(:group_formation?).and_return(false)
              end
              it { is_expected.not_to permit(user, record) }
            end

            context 'and the draw is group-formation' do
              before do
                allow(draw).to receive(:group_formation?).and_return(true)
              end
              it { is_expected.to permit(user, record) }
            end
          end
        end
      end
    end

    permissions :accept?, :reject? do
      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
          end

          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the membership is already confirmed' do
              before { allow(record).to receive(:confirmed).and_return(true) }
              it { is_expected.not_to permit(user, record) }
            end
            context 'and the membership is not confirmed' do
              before { allow(record).to receive(:confirmed).and_return(false) }

              context 'but the draw is not group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(false)
                end
                it { is_expected.not_to permit(user, record) }
              end

              context 'and the draw is group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(true)
                end
                it { is_expected.to permit(user, record) }
              end
            end
          end
        end
      end
    end

    permissions :leave? do
      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
          end

          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the membership is not confirmed' do
              before { allow(record).to receive(:confirmed).and_return(false) }
              it { is_expected.not_to permit(user, record) }
            end
            context 'and the membership is confirmed' do
              before { allow(record).to receive(:confirmed).and_return(true) }

              context 'but the draw is not group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(false)
                end
                it { is_expected.not_to permit(user, record) }
              end

              context 'and the draw is group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(true)
                end
                it { is_expected.to permit(user, record) }
              end
            end
          end
        end
      end
    end
  end

  context 'housing rep' do
    let(:user) { build_stubbed(:user, role: 'rep') }

    permissions :update?, :destroy? do
      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
          end
          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the draw is not group-formation' do
              before do
                allow(draw).to receive(:group_formation?).and_return(false)
              end
              it { is_expected.not_to permit(user, record) }
            end

            context 'and the draw is group-formation' do
              before do
                allow(draw).to receive(:group_formation?).and_return(true)
              end
              it { is_expected.to permit(user, record) }
            end
          end
        end
      end
    end

    permissions :accept?, :reject? do
      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
          end

          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the membership is already confirmed' do
              before { allow(record).to receive(:confirmed).and_return(true) }
              it { is_expected.not_to permit(user, record) }
            end
            context 'and the membership is not confirmed' do
              before { allow(record).to receive(:confirmed).and_return(false) }

              context 'but the draw is not group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(false)
                end
                it { is_expected.not_to permit(user, record) }
              end

              context 'and the draw is group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(true)
                end
                it { is_expected.to permit(user, record) }
              end
            end
          end
        end
      end
    end

    permissions :leave? do
      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
          end
          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the membership is not confirmed' do
              before { allow(record).to receive(:confirmed).and_return(false) }
              it { is_expected.not_to permit(user, record) }
            end
            context 'and the membership is confirmed' do
              before { allow(record).to receive(:confirmed).and_return(true) }

              context 'but the draw is not group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(false)
                end
                it { is_expected.not_to permit(user, record) }
              end

              context 'and the draw is group-formation' do
                before do
                  allow(draw).to receive(:group_formation?).and_return(true)
                end
                it { is_expected.to permit(user, record) }
              end
            end
          end
        end
      end
    end
  end

  context 'admin' do
    let(:user) { build_stubbed(:user, role: 'admin') }

    permissions :update?, :destroy?, :accept?, :reject?, :leave? do
      it { is_expected.not_to permit(user, record) }
    end
  end
end
