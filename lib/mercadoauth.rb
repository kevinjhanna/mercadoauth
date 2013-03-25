require "oauth2"

class MercadoAuth
  attr_accessor :access_token
  attr_accessor :redirect_uri

  OPTIONS = {
    raise_errors: true,
    parse: true,
    headers: {
      "Content-Type" => "application/json",
      "Accept"       => "application/json"
    }
  }

  def initialize(id, secret)
    @id, @secret = id, secret

    @client = OAuth2::Client.new(
      @id,
      @secret,
      site: ENV["MERCADOLIBRE_OAUTH_URL"] || "https://api.mercadolibre.com",
      authorize_url: "http://auth.mercadolibre.com/authorization?response_type=code&client_id=#{@id}",
      token_url: "oauth/token",
    )

    @redirect_uri = nil
    @access_token = nil
  end

  def access_token(code)
    params = {
      code: code,
      grant_type: :authorization_code,
      client_id: @id,
      client_secret: @secret,
      redirect_uri: @redirect_uri,
    }

    url = @client.token_url(params)

    response = @client.request(:post, url, OPTIONS)

    raise OAuth2::Error.new(response) unless response.parsed.is_a?(Hash) && response.parsed["access_token"]

    hash = response.parsed

    @access_token = build_token(hash)
  end

  def build_token(hash)
    OAuth2::AccessToken.from_hash(@client, hash.merge(mode: :query, param_name: :access_token))
  end

  def get(*args)
    @access_token.get(*args).response.body
  end

  def post(*args)
    @access_token.post(*args).response.body
  end

  def authorize_url
    @client.authorize_url
  end
end
