# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DrawlessGroupCreator do
  context 'success' do
    it 'successfully creates a group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:object]).to \
        be_instance_of(Group)
    end
    it 'removes leaders and members from existing draws if necessary' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash_with_draw_students)
      expect(described_class.new(params).create![:object]).to \
        be_instance_of(Group)
    end
    it 'automatically sets the intents of members if necessary' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash_with_undeclared_intent_student)
      expect(described_class.new(params).create![:object]).to \
        be_instance_of(Group)
    end
    it 'returns the group object' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash_with_undeclared_intent_student)
      expect(described_class.new(params).create![:record]).to \
        be_instance_of(Group)
    end
    it 'returns a success flash message' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.new(params).create![:msg]).to have_key(:success)
    end
  end

  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:object]).to be_nil
  end
  it 'returns the group object even if invalid' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:record]).to \
      be_instance_of(Group)
  end
  it 'does not persist changes to members if save fails' do
    student = FactoryGirl.create(:student, intent: 'undeclared')
    params = instance_spy('ActionController::Parameters',
                          to_h: invalid_params_hash_with_draw_student(student))
    expect { described_class.new(params).create! }.not_to \
      change { User.find(student.id).intent }
  end

  # rubocop:disable RSpec/InstanceVariable
  def params_hash(leader = nil)
    @suite ||= FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    @leader ||= leader || FactoryGirl.create(:student)
    { size: @suite.size, leader_id: @leader.id }
  end
  # rubocop:enable RSpec/InstanceVariable

  def params_hash_with_draw_students
    params_hash(FactoryGirl.create(:student_in_draw)).merge(
      member_ids: [FactoryGirl.create(:student_in_draw).id.to_s]
    )
  end

  def params_hash_with_undeclared_intent_student
    params_hash.merge(
      member_ids: [FactoryGirl.create(:student, intent: 'undeclared').id.to_s]
    )
  end

  def invalid_params_hash_with_draw_student(student)
    params_hash(student).merge(size: 0)
  end
end
