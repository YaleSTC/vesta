# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawStudentAssignmentForm, type: :model do
  let(:draw) { FactoryGirl.create(:draw) }

  describe 'validations' do
    subject(:form_object) { described_class.new(draw: draw) }

    it { is_expected.to validate_presence_of(:username) }
    # commenting this out due to a shoulda_matchers warning
    # it do
    #   is_expected.to validate_inclusion_of(:adding).in_array([true, false])
    # end
    it 'validates that a valid student is found' do
      klass = 'User::ActiveRecord_Relation'
      allow(UngroupedStudentsQuery).to receive(:call)
        .and_return(instance_spy(klass, find_by: nil))
      expect(form_object.valid?).to be_falsey
    end
  end

  describe '#submit' do
    context 'adding a user success' do
      it 'takes a username and adds the user' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: 'foo', adding: 'true')
        expect { described_class.submit(draw: draw, params: params) }.to \
          change { draw.students.count }.by(1)
      end
      it 'ignores grouped users' do
        FactoryGirl.create(:drawless_group).leader.update(username: 'foo')
        params = mock_params(username: 'foo', adding: 'true')
        expect { described_class.submit(draw: draw, params: params) }.to \
          change { draw.students.count }.by(0)
      end
      it 'sets :redirect_object as nil' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: 'foo', adding: 'true')
        result = described_class.submit(draw: draw, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object as nil' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: 'foo', adding: 'true')
        result = described_class.submit(draw: draw, params: params)
        expect(result[:update_object]).to be_nil
      end
      it 'sets a success message' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: 'foo', adding: 'true')
        result = described_class.submit(draw: draw, params: params)
        expect(result[:msg]).to have_key(:success)
      end
    end

    context 'failure' do
      it 'sets :redirect_object as nil' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: '', adding: 'true')
        result = described_class.submit(draw: draw, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object to the form object' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: '', adding: 'true')
        object = described_class.new(draw: draw, params: params)
        expect(object.submit[:update_object]).to eq(object)
      end
      it 'sets an error message' do
        FactoryGirl.create(:student, username: 'foo')
        params = mock_params(username: '', adding: 'true')
        result = described_class.submit(draw: draw, params: params)
        expect(result[:msg]).to have_key(:error)
      end
    end

    def mock_params(username: '', adding: nil)
      hash = { username: username, adding: adding }
      instance_spy('ActionController::Parameters', to_h: hash)
    end
  end
end
