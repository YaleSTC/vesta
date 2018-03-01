# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileFetcher do
  describe '#fetch' do
    FILE_CONTENTS = <<~HEREDOC
      col1,col2,col3
      foo1,foo2,foo3
      bar1,bar2,bar3
    HEREDOC

    let(:url) { 'https://foo.example.com/file.csv' }
    let(:io) { StringIO.new }

    it 'downloads a file from the internet' do
      stub_request(:get, url).to_return(body: FILE_CONTENTS)
      described_class.fetch(url: url, io: io)
      expect(File.read('tmp/file.csv')).to eq(FILE_CONTENTS)
    end
    it 'returns the file location' do
      stub_request(:get, url).to_return(body: FILE_CONTENTS)
      result = described_class.fetch(url: url, io: io)
      expect(result).to eq(Rails.root.join('tmp', 'file.csv'))
    end
    # rubocop:disable RSpec/ExampleLength
    it 'checks for an invalid non-url input' do
      begin
        obj = described_class.new(url: 'foo.csv', io: io)
        allow(obj).to receive(:open).with('foo.csv').and_raise(Errno::ENOENT)
        obj.fetch
      rescue SystemExit # since we need this to exit for the Rake task
        expect(io.string).to match(/Invalid URL/)
      end
    end
    it 'checks for an invalid URL' do
      begin
        obj = described_class.new(url: 'http://foo.com/foo.csv', io: io)
        allow(obj).to receive(:open).with('http://foo.com/foo.csv')
                                    .and_raise(Errno::ECONNREFUSED)
        obj.fetch
      rescue SystemExit # since we need this to exit for the Rake task
        expect(io.string).to match(/Unable to download/)
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
