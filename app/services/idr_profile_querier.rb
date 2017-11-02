# frozen_string_literal: true

require 'open-uri'

# Service object to query the Yale IDR web service (or one similar to it) for
# profile data. Expects an XML response, meant to be as general as possible.
class IDRProfileQuerier
  include Callable

  # Initialize a ProfileRequester
  #
  # @param id [String] the id attribute to query the web service with
  def initialize(id:)
    @id = id
    @attr_hash = {}
  end

  # Requests user profile data from a web service
  #
  # @return [Hash{Symbol=>String},nil] either returns a hash with profile
  #   attributes that can be used to assign_attributes on a user record or nil
  #   if the lookup failed
  def query
    return attr_hash unless all_config_params_defined?
    build_request
    issue_request
    parse_results
    attr_hash
  end

  make_callable :query

  private

  attr_accessor :attr_hash
  attr_reader :id, :response, :uri, :http_request

  CONFIG_PARAM_HEADER = 'PROFILE_REQUEST_'
  PROFILE_FIELDS =
    %i(first_name last_name email class_year).freeze
  REQUIRED_CONFIG_PARAMS =
    (%w(URL QUERY_PARAM) + PROFILE_FIELDS.map { |f| f.to_s.upcase }).freeze

  def all_config_params_defined?
    required_config_params.all? { |param| env?(param) }
  end

  def required_config_params
    REQUIRED_CONFIG_PARAMS.map { |param| CONFIG_PARAM_HEADER + param }
  end

  def build_request
    @uri ||= URI(url_str)
    @http_request ||= Net::HTTP::Get.new(uri)
    @http_request.basic_auth(username, password) if basic_auth?
  end

  def url_str
    env(config_var('URL')) + '?' + env(config_var('QUERY_PARAM')) + "=#{id}"
  end

  def basic_auth?
    env?(config_var('USERNAME')) && env?(config_var('PASSWORD'))
  end

  def config_var(param)
    CONFIG_PARAM_HEADER + param
  end

  def username
    env(config_var('USERNAME'))
  end

  def password
    env(config_var('PASSWORD'))
  end

  def issue_request
    @response ||= Net::HTTP.start(uri.hostname, uri.port,
                                  use_ssl: use_ssl?) do |http|
      http.request(http_request)
    end
  end

  def use_ssl?
    !url_str.match(/https/).nil?
  end

  def parse_results
    xml = Nokogiri::XML(response.body)
    PROFILE_FIELDS.each do |field|
      attr_hash.store(field, extract_data(xml, field))
    end
  end

  def extract_data(xml, field_key)
    tag = env(config_var(field_key.to_s.upcase))
    xml.at_xpath("//#{tag}")&.content
  end
end
