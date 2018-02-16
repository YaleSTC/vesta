# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
require 'rails_helper'

RSpec.describe ClipPolicy do
  subject { described_class }

  let(:clip) { FactoryGirl.build_stubbed(:clip) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :show? do
      it { is_expected.to permit(user, clip) }
    end

    permissions :create? do
      let(:group) { instance_spy('Group', present?: true) }

      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, clip) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before { allow(group).to receive(:leader).and_return(nil) }
          it { is_expected.not_to permit(user, clip) }
        end
        context 'and leads it' do
          before { allow(group).to receive(:leader).and_return(user) }

          context 'but is in a clip' do
            before do
              existing_clip = instance_spy('Clip')
              allow(group).to receive(:clip).and_return(existing_clip)
            end
            it { is_expected.not_to permit(user, clip) }
          end

          context 'and is not in a clip' do
            let(:draw) { instance_spy('Draw') }

            before do
              allow(group).to receive(:clip).and_return(nil)
              allow(clip).to receive(:draw).and_return(draw)
            end

            context 'but the draw is not in a pre-lottery stage' do
              before do
                allow(draw).to receive(:pre_lottery?).and_return(false)
              end
              it { is_expected.not_to permit(user, clip) }
            end

            context 'and is in a pre-lottery draw' do
              before do
                allow(draw).to receive(:pre_lottery?).and_return(true)
              end

              context 'but the draw does not allow for clipping' do
                before do
                  allow(draw).to receive(:allow_clipping).and_return(false)
                end
                it { is_expected.not_to permit(user, clip) }
              end
              context 'and the draw allows for clipping' do
                before do
                  allow(draw).to receive(:allow_clipping).and_return(true)
                end
                it { is_expected.to permit(user, clip) }
              end
            end
          end
        end
      end
    end

    permissions :create_as_rep?, :edit?, :update?, :destroy? do
      it { is_expected.not_to permit(user, clip) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :show?, :create? do
      it { is_expected.to permit(user, clip) }
    end

    permissions :create_as_rep? do
      let(:group) { instance_spy('Group', present?: true) }

      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, clip) }
      end
      context 'in a group' do
        let(:draw) { instance_spy('Draw') }

        before do
          allow(user).to receive(:group).and_return(group)
          allow(clip).to receive(:draw).and_return(draw)
        end

        context 'but the draw is not in a pre-lottery stage' do
          before do
            allow(draw).to receive(:pre_lottery?).and_return(false)
          end
          it { is_expected.not_to permit(user, clip) }
        end

        context 'and is in a pre-lottery draw' do
          before do
            allow(draw).to receive(:pre_lottery?).and_return(true)
          end

          context 'but the draw does not allow for clipping' do
            before do
              allow(draw).to receive(:allow_clipping).and_return(false)
            end
            it { is_expected.not_to permit(user, clip) }
          end
          context 'and the draw allows for clipping' do
            before do
              allow(draw).to receive(:allow_clipping).and_return(true)
            end
            it { is_expected.to permit(user, clip) }
          end
        end
      end
    end

    permissions :edit?, :update?, :destroy? do
      it { is_expected.not_to permit(user, clip) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :show? do
      it { is_expected.to permit(user, clip) }
    end

    permissions :create? do
      let(:draw) { instance_spy('Draw') }

      context 'the draw is not pre_lottery' do
        before do
          allow(clip).to receive(:draw).and_return(draw)
          allow(draw).to receive(:pre_lottery?).and_return(false)
        end
        it { is_expected.not_to permit(user, clip) }
      end

      context 'the draw is pre_lottery' do
        before do
          allow(clip).to receive(:draw).and_return(draw)
          allow(draw).to receive(:pre_lottery?).and_return(true)
        end

        context 'but the draw does not allow for clipping' do
          before do
            allow(draw).to receive(:allow_clipping).and_return(false)
          end
          it { is_expected.not_to permit(user, clip) }
        end
        context 'and the draw allows for clipping' do
          before do
            allow(draw).to receive(:allow_clipping).and_return(true)
          end
          it { is_expected.to permit(user, clip) }
        end
      end
    end

    permissions :edit?, :update?, :destroy? do
      let(:draw) { instance_spy('Draw') }

      context 'the draw is not pre_lottery' do
        before do
          allow(clip).to receive(:draw).and_return(draw)
          allow(draw).to receive(:pre_lottery?).and_return(false)
        end
        it { is_expected.not_to permit(user, clip) }
      end

      context 'the draw is pre_lottery' do
        before do
          allow(clip).to receive(:draw).and_return(draw)
          allow(draw).to receive(:pre_lottery?).and_return(true)
        end
        it { is_expected.to permit(user, clip) }
      end
    end

    permissions :create_as_rep? do
      it { is_expected.not_to permit(user, clip) }
    end
  end
end
