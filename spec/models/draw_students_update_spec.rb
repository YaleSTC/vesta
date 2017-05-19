# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawStudentsUpdate do
  describe '#update' do
    context 'success' do
      it 'bulk-adds users of a passed class year' do
        draw = FactoryGirl.create(:draw)
        FactoryGirl.create(:student, class_year: 2016)
        params = mock_params(class_year: '2016', to_add: nil)
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.students.count }.by(1)
      end
      it 'ignores students that are in other draws or groups' do
        draw = FactoryGirl.create(:draw)
        create_students_in_year(2016)
        params = mock_params(class_year: '2016', to_add: nil)
        expect { described_class.update(draw: draw, params: params) }.to \
          change { draw.students.count }.by(1)
      end
      it 'sets :redirect_object to nil' do
        draw = FactoryGirl.create(:draw)
        FactoryGirl.create(:student, class_year: 2016)
        params = mock_params(class_year: '2016')
        result = described_class.update(draw: draw, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object to nil' do
        draw = FactoryGirl.create(:draw)
        FactoryGirl.create(:student, class_year: 2016)
        params = mock_params(class_year: '2016')
        result = described_class.update(draw: draw, params: params)
        expect(result[:update_object]).to be_nil
      end
      it 'sets a success message' do
        draw = FactoryGirl.create(:draw)
        FactoryGirl.create(:student, class_year: 2016)
        params = mock_params(class_year: '2016')
        result = described_class.update(draw: draw, params: params)
        expect(result[:msg]).to have_key(:success)
      end
      def create_students_in_year(year)
        FactoryGirl.create(:student_in_draw, class_year: year)
        student_in_group = FactoryGirl.create(:drawless_group).leader
        student_in_group.update(class_year: year)
        FactoryGirl.create(:student, class_year: year)
      end
    end

    context 'warning' do
      it 'sets :redirect_object to nil' do
        draw = FactoryGirl.create(:draw)
        result = described_class.update(draw: draw, params: mock_params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object to the update object' do
        draw = FactoryGirl.create(:draw)
        update_object = described_class.new(draw: draw, params: mock_params)
        expect(update_object.update[:update_object]).to eq(update_object)
      end
      it 'sets an alert message' do
        draw = FactoryGirl.create(:draw)
        result = described_class.update(draw: draw, params: mock_params)
        expect(result[:msg]).to have_key(:alert)
      end
    end

    context 'error' do
      it 'sets :redirect_object to nil' do
        draw = FactoryGirl.create(:draw)
        bad_user = create_bad_user
        params = mock_params(class_year: bad_user.class_year.to_s)
        result = described_class.update(draw: draw, params: params)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets :update_object to the update object' do
        draw = FactoryGirl.create(:draw)
        bad_user = create_bad_user
        params = mock_params(class_year: bad_user.class_year.to_s)
        update_object = described_class.new(draw: draw, params: params)
        expect(update_object.update[:update_object]).to eq(update_object)
      end
      it 'sets an error message' do
        draw = FactoryGirl.create(:draw)
        bad_user = create_bad_user
        params = mock_params(class_year: bad_user.class_year.to_s)
        result = described_class.update(draw: draw, params: params)
        expect(result[:msg]).to have_key(:error)
      end

      def create_bad_user
        klass = 'User::ActiveRecord_Relation'
        FactoryGirl.create(:student, class_year: 2016).tap do |s|
          allow(UngroupedStudentsQuery).to receive(:call)
            .and_return(instance_spy(klass, where: [s]))
          allow(s).to receive(:update).and_raise(ActiveRecord::RecordInvalid)
        end
      end
    end

    def mock_params(class_year: '', to_add: '')
      hash = { class_year: class_year, to_add: to_add }
      instance_spy('ActionController::Parameters', to_h: hash)
    end
  end
end
