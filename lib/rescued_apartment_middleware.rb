# frozen_string_literal: true

# Middleware layer to rescue from a missing tenant (invalid subdomain)
# Inspired by https://stackoverflow.com/a/28233828/2187922
module RescuedApartmentMiddleware
  def call(*args)
    super
  rescue Apartment::TenantNotFound
    # Extract the Rack env and create a dummy Rack::Request object
    env = args.first
    request = Rack::Request.new(env)
    # Display an error message
    Rails.logger.error "Error: #{parse_tenant_name(request)} college not found"
    # Continue if we're going to the naked canonical host
    return @app.call(*args) if visiting_canonical_host?(env)
    # Otherwise, 301 redirect to the host without the first subdomain until we
    # hit a valid college or our canonical host. This is guaranteed because the
    # rack_canonical_host gem will ensure that any request received with any
    # subdomain but a non-canonical host will be redirected to the subdomain on
    # top of the canonical host.
    return [301, { 'location' => redirect_location(env) }, []]
  end

  private

  def visiting_canonical_host?(env)
    current_host(env) == ENV.fetch('APPLICATION_HOST')
  end

  def current_host(env)
    env['HTTP_HOST']
  end

  def redirect_location(env)
    "#{protocol(env)}://#{stripped_host(env)}"
  end

  # inspired by https://github.com/josh/rack-ssl/blob/master/lib/rack/ssl.rb#L38
  def protocol(env)
    if env['HTTPS'] == 'on'
      'https'
    elsif env['HTTP_X_FORWARDED_PROTO']
      env['HTTP_X_FORWARDED_PROTO'].split(',')[0]
    else
      env['rack.url_scheme']
    end
  end

  def stripped_host(env)
    host = current_host(env)
    host.split('.').drop(1).join('.')
  end
end
