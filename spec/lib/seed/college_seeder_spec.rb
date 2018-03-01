# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollegeSeeder do
  describe '#seed' do
    context 'success' do
      let(:college) { instance_spy('college', subdomain: 'foo') }
      let(:io) { StringIO.new }

      before do
        allow(Generator).to receive(:generate)
        allow(College).to receive(:find_by!).with(subdomain: 'foo')
                                            .and_return(college)
      end

      shared_examples 'creates the right data' do |model|
        it "generates #{model.pluralize}" do
          described_class.seed(subdomain: 'foo', io: io)
          expect(Generator).to have_received(:generate)
            .with(hash_including(model: model)).at_least(:once)
        end
      end

      it_behaves_like 'creates the right data', 'user'
      it_behaves_like 'creates the right data', 'building'
      it_behaves_like 'creates the right data', 'suite'
      it_behaves_like 'creates the right data', 'room'

      it 'ensures that there are no empty suites' do
        relation = instance_spy('Suite::ActiveRecord_Relation')
        allow(Suite).to receive(:where).with(size: 0).and_return(relation)
        described_class.seed(subdomain: 'foo', io: io)
        expect(relation).to have_received(:destroy_all).once
      end
    end

    it 'checks subdomain validity' do # rubocop:disable RSpec/ExampleLength
      begin
        io = StringIO.new
        described_class.seed(subdomain: 'not_valid', io: io)
      rescue SystemExit # since we need this to exit for the Rake task
        expect(io.string).to eq("Invalid college subdomain: not_valid\n")
      end
    end
  end
end
