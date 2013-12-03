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

  INVALID_URL = Error.new("invalid_url", "Not a valid URL.")

  class Client
    HTTP_ENDPOINT = "http://api.sharedcount.com/".freeze
    HTTPS_ENDPOINT = "https://sharedcount.appspot.com/".freeze

    def initialize(url, use_ssl = false)
      @url, @use_ssl = url, use_ssl
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

  private

    def facebook_metrics
      @facebook_metrics ||= response["Facebook"].is_a?(Hash) ? response["Facebook"] : Hash.new(0)
    end

    def response
      @response ||= begin
        endpoint = @use_ssl ? HTTPS_ENDPOINT : HTTP_ENDPOINT
        begin
          uri = URI("#{endpoint}?url=#{@url}")
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
  end
end
