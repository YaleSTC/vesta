# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollegeProvisioner do
  VALID_CSV_LINES = ['name,subdomain', 'Foo,foo', 'Bar,bar'].freeze
  INVALID_CSV_LINES = ['invalid,header', 'Foo,foo'].freeze

  describe '#provision' do
    let(:io) { StringIO.new }

    context 'valid' do
      before do
        stub_csv_reader(filename: 'foo.csv', out: VALID_CSV_LINES)
        allow(UserCloner).to receive(:clone)
        allow(CollegeSeeder).to receive(:seed)
      end

      it 'creates a college for each row in the CSV file' do
        expect { described_class.provision(filename: 'foo.csv', io: io) }.to \
          change { College.count }.by(2)
      end
      it 'clones the first superuser in the first college to new colleges' do
        create_superuser(email: 'foo@example.com')
        described_class.provision(filename: 'foo.csv', io: io)
        expect(UserCloner).to have_received(:clone)
          .with(username: 'foo@example.com', io: io)
      end
      it 'optionally seeds each new college' do
        described_class.provision(filename: 'foo.csv', io: io, seed: true)
        %w(foo bar).each do |subdomain|
          expect(CollegeSeeder).to have_received(:seed)
            .with(subdomain: subdomain, io: io)
        end
      end
    end

    it 'checks for invalid CSV headers' do # rubocop:disable RSpec/ExampleLength
      begin
        stub_csv_reader(filename: 'foo.csv', out: INVALID_CSV_LINES)
        described_class.provision(filename: 'foo.csv', io: io)
      rescue SystemExit # since we need this to exit for the Rake task
        msg = "Invalid CSV file - must include the header \"name,subdomain\"\n"
        expect(io.string).to eq(msg)
      end
    end
  end

  def stub_csv_reader(filename:, out:)
    allow(CSVReader).to receive(:read).with(filename: filename).and_return(out)
  end

  def create_superuser(email:)
    College.first.activate!
    create(:user, role: 'superuser', email: email)
  end
end
