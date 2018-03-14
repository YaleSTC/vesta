# frozen_string_literal: true

require 'rails_helper'

REQUIRED_CONFIG_PARAMS =
  %w(PROFILE_REQUEST_URL PROFILE_REQUEST_QUERY_PARAM PROFILE_REQUEST_FIRST_NAME
     PROFILE_REQUEST_LAST_NAME PROFILE_REQUEST_EMAIL
     PROFILE_REQUEST_CLASS_YEAR).freeze
DUMMY_XML_RESPONSE =
  <<~HEREDOC
    <?xml version="1.0" encoding="UTF-8"?>
    <ServiceResponse>
      <Record>
          <Login>bar</Login>
          <FirstName>Jane</FirstName>
          <LastName>Smith</LastName>
          <Email>jane.smith@example.com</Email>
          <AltId>123456</AltId>
          <ClassYear>2018</ClassYear>
      </Record>
    </ServiceResponse>
  HEREDOC
DUMMY_PROFILE_HASH = { first_name: 'Jane', last_name: 'Smith',
                       email: 'jane.smith@example.com',
                       class_year: '2018' }.freeze

RSpec.describe IDRProfileQuerier do
  describe '#query' do
    context 'success' do
      before do
        assign_required_attributes
        stub_profile_request
      end
      it 'returns full profile data with CAS' do
        allow(User).to receive(:cas_auth?).and_return(true)
        result = described_class.query(id: 'bar')
        expect(result).to eq(DUMMY_PROFILE_HASH)
      end
      it 'does not return e-mail when not using CAS' do
        allow(User).to receive(:cas_auth?).and_return(false)
        result = described_class.query(id: 'bar')
        expect(result).to eq(DUMMY_PROFILE_HASH.except(:email))
      end
    end

    context 'missing config params' do
      before { allow(ENV).to receive(:[]).with(any_args).and_return(true) }
      REQUIRED_CONFIG_PARAMS.each do |param|
        it "returns an empty hash if missing #{param}" do
          allow(ENV).to receive(:[]).with(param).and_return(false)
          result = described_class.query(id: 'foo')
          expect(result).to eq({})
        end
      end
    end
  end

  def mock_profile_querier(**params)
    instance_spy('IDRProfileQuerier').tap do |profile_querier|
      allow(IDRProfileQuerier).to receive(:new).with(**params)
                                               .and_return(profile_querier)
    end
  end

  def assign_required_attributes
    allow(ENV).to receive(:[]).and_return(nil)
    REQUIRED_CONFIG_PARAMS.each do |param|
      val = mock_val(param)
      allow(ENV).to receive(:[]).with(param).and_return(val)
    end
  end

  def mock_val(param)
    return 'https://foo.example.com/' unless param.match(/URL/).nil?
    return 'foo' unless param.match(/QUERY_PARAM/).nil?
    param_tag(param)
  end

  def param_tag(param)
    param.gsub('PROFILE_REQUEST_', '').split('_').map(&:capitalize).join('')
  end

  def stub_profile_request(id: 'bar')
    stub_request(:get, 'https://foo.example.com')
      .with(query: { 'foo' => id })
      .to_return(body: DUMMY_XML_RESPONSE)
  end
end
