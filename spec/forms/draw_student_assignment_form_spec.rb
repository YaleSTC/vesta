# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawStudentAssignmentForm, type: :model do
  let(:draw) { create(:draw) }

  describe 'validations' do
    subject(:form_object) { described_class.new(draw: draw) }

    it { is_expected.to validate_presence_of(:login) }
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

  shared_examples 'assignment querying with' do |qtype|
    describe '#submit' do
      let(:student_params) { { username: 'foo', email: 'foo@m.com' } }
      let(:login) { student_params[qtype] }

      before { allow(User).to receive(:login_attr).and_return(qtype) }

      context 'adding a user success' do
        it 'takes a username and adds the user' do
          create(:student_in_draw, student_params)
          params = mock_params(login: login, adding: 'true')
          expect { described_class.submit(draw: draw, params: params) }.to \
            change { draw.students.count }.by(1)
        end
        it 'ignores grouped users' do
          create(:drawless_group).leader.update(student_params)
          params = mock_params(login: login, adding: 'true')
          expect { described_class.submit(draw: draw, params: params) }.to \
            change { draw.students.count }.by(0)
        end
        it 'sets :redirect_object as nil' do
          create(:student_in_draw, student_params)
          params = mock_params(login: login, adding: 'true')
          result = described_class.submit(draw: draw, params: params)
          expect(result[:redirect_object]).to be_nil
        end
        it 'sets :update_object as nil' do
          create(:student_in_draw, student_params)
          params = mock_params(login: login, adding: 'true')
          result = described_class.submit(draw: draw, params: params)
          expect(result[:update_object]).to be_nil
        end
        it 'sets a success message' do
          create(:student_in_draw, student_params)
          params = mock_params(login: login, adding: 'true')
          result = described_class.submit(draw: draw, params: params)
          expect(result[:msg]).to have_key(:success)
        end
      end

      context 'failure' do
        it 'sets :redirect_object as nil' do
          create(:student_in_draw, student_params)
          params = mock_params(login: '', adding: 'true')
          result = described_class.submit(draw: draw, params: params)
          expect(result[:redirect_object]).to be_nil
        end
        it 'sets :update_object to the form object' do
          create(:student_in_draw, student_params)
          params = mock_params(login: '', adding: 'true')
          object = described_class.new(draw: draw, params: params)
          expect(object.submit[:update_object]).to eq(object)
        end
        it 'sets an error message' do
          create(:student_in_draw, student_params)
          params = mock_params(login: '', adding: 'true')
          result = described_class.submit(draw: draw, params: params)
          expect(result[:msg]).to have_key(:error)
        end
      end

      def mock_params(login: '', adding: nil)
        hash = { login: login, adding: adding }
        instance_spy('ActionController::Parameters', to_h: hash)
      end
    end
  end

  it_behaves_like 'assignment querying with', :email
  it_behaves_like 'assignment querying with', :username
end
