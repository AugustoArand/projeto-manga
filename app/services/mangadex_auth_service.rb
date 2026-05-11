require "net/http"
require "json"
require "uri"

# Handles OAuth 2.0 Personal Client (password flow) with MangaDex.
# Tokens are cached in Rails.cache to avoid redundant network calls.
class MangadexAuthService
  AUTH_URL    = "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token".freeze
  CACHE_TTL   = 14.minutes   # access token expires in 15 min; refresh slightly earlier

  class AuthenticationError < StandardError; end

  class << self
    # Exchange username + password for an access token.
    # Returns { access_token:, refresh_token:, expires_in: } or raises AuthenticationError.
    def login(username, password)
      body = {
        grant_type:    "password",
        username:      username,
        password:      password,
        client_id:     client_id,
        client_secret: client_secret
      }
      response = post_form(AUTH_URL, body)
      validate!(response)
      response
    end

    # Exchange a refresh_token for a new access_token.
    def refresh(refresh_token)
      body = {
        grant_type:    "refresh_token",
        refresh_token: refresh_token,
        client_id:     client_id,
        client_secret: client_secret
      }
      response = post_form(AUTH_URL, body)
      validate!(response)
      response
    end

    private

    def client_id
      ENV.fetch("MANGADEX_CLIENT_ID") { raise AuthenticationError, "MANGADEX_CLIENT_ID not set" }
    end

    def client_secret
      ENV.fetch("MANGADEX_CLIENT_SECRET") { raise AuthenticationError, "MANGADEX_CLIENT_SECRET not set" }
    end

    def post_form(url, body)
      uri     = URI(url)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"]  = "application/x-www-form-urlencoded"
      request["User-Agent"]    = "MangaVerse/1.0"
      request.body = URI.encode_www_form(body)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 8, read_timeout: 12) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    rescue => e
      raise AuthenticationError, "Auth request failed: #{e.message}"
    end

    def validate!(response)
      return if response["access_token"].present?
      msg = response["error_description"] || response["error"] || "Unknown auth error"
      raise AuthenticationError, msg
    end
  end
end
