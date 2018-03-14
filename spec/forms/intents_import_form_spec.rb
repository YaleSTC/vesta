# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IntentsImportForm do
  include ActionDispatch::TestProcess

  context 'valid csv' do
    let(:students) { instance_spy('User::ActiveRecord_Relation') }
    let(:user) { instance_spy('User') }

    before { allow(students).to receive(:find_by!).and_return(user) }

    context 'with cas' do
      let(:file) { fixture_file_upload(csv_path('intent_cas'), 'text/csv') }

      before { allow(User).to receive(:login_attr).and_return(:username) }

      it 'updates the users' do
        # from the fixture
        count = 3
        described_class.import(file: file, students: students)
        expect(user).to have_received(:update!).exactly(count).times
      end
      it 'returns nil in :redirect_object' do
        result = described_class.import(file: file, students: students)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns a success flash' do
        # from the fixture
        count = 3
        result = described_class.import(file: file, students: students)[:msg]
        expect(result[:success]).to match(/updated #{count} intents./)
      end
      it 'raises an error with the wrong headers' do
        # this tests that the headers from the non-cas file fail with cas
        file = fixture_file_upload(csv_path('intent_upload'), 'text/csv')
        result = described_class.import(file: file, students: students)[:msg]
        expect(result[:error]).to match(/Header incorrect/)
      end
    end
    context 'without cas' do
      let(:file) { fixture_file_upload(csv_path('intent_upload'), 'text/csv') }

      before { allow(User).to receive(:login_attr).and_return(:email) }

      it 'updates the users' do
        # from the fixture
        count = 3
        described_class.import(file: file, students: students)
        expect(user).to have_received(:update!).exactly(count).times
      end
      it 'returns nil in :redirect_object' do
        result = described_class.import(file: file, students: students)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns a success flash' do
        # from the fixture
        count = 3
        result = described_class.import(file: file, students: students)[:msg]
        expect(result[:success]).to match(/updated #{count} intents./)
      end
      it 'raises an error with the wrong headers' do
        # this tests that the headers from the cas file fail without cas
        file = fixture_file_upload(csv_path('intent_cas'), 'text/csv')
        result = described_class.import(file: file, students: students)[:msg]
        expect(result[:error]).to match(/Header incorrect/)
      end
    end
  end

  context 'missing header' do
    let(:students) { instance_spy('User::ActiveRecord_Relation') }
    let(:user) { instance_spy('User') }
    let(:file) { fixture_file_upload(csv_path('intent_no_header'), 'text/csv') }

    before { allow(students).to receive(:find_by!).and_return(user) }

    it 'updates no users' do
      described_class.import(file: file, students: students)
      expect(user).not_to have_received(:update!)
    end
    it 'returns nil in :redirect_object' do
      result = described_class.import(file: file, students: students)
      expect(result[:redirect_object]).to be_nil
    end
    it 'returns an error flash' do
      result = described_class.import(file: file, students: students)
      expect(result[:msg].keys).to eq([:error])
    end
  end

  context 'some create failures' do
    let(:students) { instance_spy('User::ActiveRecord_Relation') }
    let(:user) { instance_spy('User') }
    let(:file) { fixture_file_upload(csv_path('intent_upload'), 'text/csv') }

    before do
      # the file attempts to update one user to on_campus and two to off_campus
      allow(students).to receive(:find_by!).and_return(user)
      allow(user).to receive(:update!).with(intent: 'on_campus')
                                      .and_raise(ActiveRecord::RecordInvalid)
      allow(user).to receive(:update!).with(intent: 'off_campus')
    end

    it 'returns nil in :redirect_object' do
      result = described_class.import(file: file, students: students)
      expect(result[:redirect_object]).to be_nil
    end
    it 'returns an error flash and a success flash' do
      result = described_class.import(file: file, students: students)
      expect(result[:msg].keys).to match_array(%i(success error))
    end
    it 'properly adds the failing number to the flash message' do
      result = described_class.import(file: file, students: students)
      expect(result[:msg][:error]).to match(/email1@email.com/)
    end
  end

  def csv_path(filename)
    Rails.root.join('spec', 'fixtures', "#{filename}.csv")
  end
end
