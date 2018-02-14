# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawSuitePolicy do
  subject { described_class }

  let(:draw_suite) { instance_spy('draw_suite') }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :index? do
      context 'not draft' do
        before do
          draw = instance_spy('draw', draft?: false)
          allow(draw_suite).to receive(:draw).and_return(draw)
        end
        it { is_expected.to permit(user, draw_suite) }
      end
      context 'draft' do
        before do
          draw = instance_spy('draw', draft?: true)
          allow(draw_suite).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, draw_suite) }
      end
    end

    permissions :edit_collection?, :update_collection? do
      it { is_expected.not_to permit(user, draw_suite) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :index? do
      it { is_expected.to permit(user, draw_suite) }
    end
    permissions :edit_collection?, :update_collection? do
      context 'draw not before lottery' do
        before do
          draw = instance_spy('draw', before_lottery?: false)
          allow(draw_suite).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, draw_suite) }
      end
      context 'draw before lottery' do
        before do
          draw = instance_spy('draw', before_lottery?: true)
          allow(draw_suite).to receive(:draw).and_return(draw)
        end
        it { is_expected.to permit(user, draw_suite) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :index? do
      it { is_expected.to permit(user, draw_suite) }
    end
    permissions :edit_collection?, :update_collection? do
      context 'draw not before lottery' do
        before do
          draw = instance_spy('draw', before_lottery?: false)
          allow(draw_suite).to receive(:draw).and_return(draw)
        end
        it { is_expected.not_to permit(user, draw_suite) }
      end
      context 'draw before lottery' do
        before do
          draw = instance_spy('draw', before_lottery?: true)
          allow(draw_suite).to receive(:draw).and_return(draw)
        end
        it { is_expected.to permit(user, draw_suite) }
      end
    end
  end
end
