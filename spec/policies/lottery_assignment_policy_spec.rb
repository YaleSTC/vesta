# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteryAssignmentPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    let(:draw) { FactoryGirl.build_stubbed(:draw, status: 'lottery') }
    let(:lottery) { LotteryAssignment.new(draw: draw) }

    permissions :index?, :create?, :update?, :automatic?, :export? do
      it { is_expected.not_to permit(user, lottery) }
    end
  end

  context 'rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    context 'draw in lottery' do
      let(:draw) { FactoryGirl.build_stubbed(:draw, status: 'lottery') }
      let(:lottery) { LotteryAssignment.new(draw: draw) }

      permissions :index?, :create?, :update?, :export? do
        it { is_expected.to permit(user, lottery) }
      end

      permissions :automatic? do
        it { is_expected.not_to permit(user, lottery) }
      end
    end
    context 'draw not in lottery' do
      let(:draw) { FactoryGirl.build_stubbed(:draw, status: 'pre_lottery') }
      let(:lottery) { LotteryAssignment.new(draw: draw) }

      permissions :index?, :create?, :update?, :automatic?,
                  :export? do
        it { is_expected.not_to permit(user, lottery) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :index?, :create?, :update?, :automatic?, :export? do
      context 'draw in lottery' do
        let(:draw) { FactoryGirl.build_stubbed(:draw, status: 'lottery') }
        let(:lottery) { LotteryAssignment.new(draw: draw) }

        it { is_expected.to permit(user, lottery) }
      end
      context 'draw not in lottery' do
        let(:draw) { FactoryGirl.build_stubbed(:draw, status: 'pre_lottery') }
        let(:lottery) { LotteryAssignment.new(draw: draw) }

        it { is_expected.not_to permit(user, lottery) }
      end
    end
  end
end
