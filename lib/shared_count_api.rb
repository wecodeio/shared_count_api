require_relative "shared_count_api/version"
require "net/http"
require "json"
require "ostruct"

module SharedCountApi
  class Error < StandardError
    attr_reader :type, :error

    def initialize(type, message)
      @type, @message = type, message
    end
  end

  class << self
    attr_accessor :apikey, :url

    # config/initializers/shared_count_api.rb (for instance)
    #
    # SharedCountApi.configure do |config|
    #   config.apikey = 'my-api-key'
    #   config.url = 'my-dedicated-url'  # only use if you have a dedicated url plan
    # end
    #
    # elsewhere
    #
    # client = SharedCountApi::Client.new
    def configure
      yield self
      true
    end

  end

  INVALID_URL = Error.new("invalid_url", "Not a valid URL.")

  class Client
    HTTP_ENDPOINT = "http://free.sharedcount.com".freeze
    HTTPS_ENDPOINT = "https://free.sharedcount.com".freeze

    def initialize(url, use_ssl = false)
      @url, @use_ssl = URI.escape(url), use_ssl

      if SharedCountApi.url
        @endpoint = SharedCountApi.url
      else
        @endpoint = @use_ssl ? HTTPS_ENDPOINT : HTTP_ENDPOINT
      end
    end

    def stumble_upon
      response["StumbleUpon"]
    end

    def reddit
      response["Reddit"]
    end

    def facebook_like_count
      facebook_metrics["like_count"]
    end

    def facebook_share_count
      facebook_metrics["share_count"]
    end

    def facebook_comments
      facebook_metrics["comment_count"]
    end

    def delicious
      response["Delicious"]
    end

    def google_plus_one
      response["GooglePlusOne"]
    end

    def buzz
      response["Buzz"]
    end

    def twitter
      response["Twitter"]
    end

    def diggs
      response["Diggs"]
    end

    def pinterest
      response["Pinterest"]
    end

    def linked_in
      response["LinkedIn"]
    end

    def response
      @response ||= begin
        begin
          uri = if SharedCountApi.apikey
            URI("#{@endpoint}?url=#{@url}&apikey=#{SharedCountApi.apikey}")
          else
            URI("#{@endpoint}?url=#{@url}")
          end

          res = Net::HTTP.get_response(uri)

          case res
          when Net::HTTPUnauthorized, Net::HTTPBadRequest then
            json = JSON.parse(res.body)
            raise Error.new(json["Type"], json["Error"])
          when Net::HTTPSuccess then
            JSON.parse(res.body)
          end
        rescue URI::InvalidURIError
          raise INVALID_URL
        end
      end
    end

  private

    def facebook_metrics
      @facebook_metrics ||= response["Facebook"].is_a?(Hash) ? response["Facebook"] : Hash.new(0)
    end
  end
end
