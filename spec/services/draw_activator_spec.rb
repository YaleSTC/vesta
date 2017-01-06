# frozen_string_literal: true
require 'spec_helper'

RSpec.describe DrawActivator do
  # we may want to extract this into a shared example if we use this pattern
  # across all of our service objects
  describe '.start' do
    it 'calls :start on an instance of DrawStarter' do
      draw = instance_spy('draw')
      draw_activator = mock_draw_activator(draw: draw)
      described_class.activate(draw: draw)
      expect(draw_activator).to have_received(:activate)
    end
  end

  describe '#activate' do
    it 'checks to make sure that the draw is a draft' do
      draw = instance_spy('draw', draft?: false)
      result = described_class.activate(draw: draw)
      expect(result[:msg][:error]).to include('Draw must be a draft.')
    end

    it 'checks to make sure that the draw has at least one student' do
      draw = instance_spy('draw', students?: false)
      result = described_class.activate(draw: draw)
      expect(result[:msg][:error]).to \
        include('Draw must have at least one student.')
    end

    it 'checks to make sure that there are enough beds for students' do
      draw = instance_spy('draw', enough_beds?: false)
      result = described_class.activate(draw: draw)
      expect(result[:msg][:error]).to \
        include('Draw must have at least one bed per student')
    end

    it 'updates the status of the draw to pre_lottery' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      described_class.activate(draw: draw)
      expect(draw).to have_received(:update).with(status: 'pre_lottery')
    end

    it 'checks to see if the update works' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      allow(draw).to receive(:update).and_return(false)
      result = described_class.activate(draw: draw)
      expect(result[:msg][:error]).to include('Draw update failed.')
    end

    it 'sends invitations to the students in the draw' do
      draw = valid_mock_draw_with_students(num_students: 2)
      mailer = instance_spy('student_mailer')
      described_class.new(draw: draw, mailer: mailer).activate
      expect(mailer).to have_received(:draw_invitation).twice
    end

    it 'does not send emails if updating fails' do
      draw = valid_mock_draw_with_students
      allow(draw).to receive(:update).and_return(false)
      mailer = instance_spy('student_mailer')
      described_class.new(draw: draw, mailer: mailer).activate
      expect(mailer).not_to have_received(:draw_invitation)
    end

    it 'returns the updated draw on success' do
      draw = instance_spy('draw', validity_stubs(valid: true))
      result = described_class.activate(draw: draw)
      expect(result[:object]).to eq(draw)
    end

    it 'sets the object key to nil in the hash on failure' do
      draw = instance_spy('draw', validity_stubs(valid: false))
      result = described_class.activate(draw: draw)
      expect(result[:object]).to be_nil
    end
  end

  def mock_draw_activator(param_hash)
    instance_spy('draw_activator').tap do |draw_activator|
      allow(described_class).to receive(:new).with(param_hash)
        .and_return(draw_activator)
    end
  end

  def valid_mock_draw_with_students(num_students: 2)
    students = Array.new(num_students) { instance_spy('user') }
    instance_spy('draw', validity_stubs(valid: true, students: students))
  end

  def validity_stubs(valid:, **attrs)
    { draft?: valid, students?: valid, enough_beds?: valid }.merge(attrs)
  end
end
