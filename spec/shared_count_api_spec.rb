require "bundler/setup"
require "minitest/autorun"
require "minitest/pride"
require "webmock/minitest"
require "uri"
require "json"
require "pathname"

require_relative "../lib/shared_count_api"

describe SharedCountApi::Client do
  let(:url) { "http://slashdot.org" }
  let(:body) do
    { StumbleUpon: 603192, Reddit: 0,
      Facebook: { commentsbox_count: 15, click_count: 27523, total_count: 335835, comment_count: 100278,
                  like_count: 84709, share_count: 150848},
      Delicious: 11969, GooglePlusOne: 76352, Buzz: 0, Twitter: 22199, Diggs: 0, Pinterest: 16081,
      LinkedIn: 1532 }
  end
  subject { SharedCountApi::Client.new(url) }

  describe "when the free API quota has been exceeded" do
    before do
      body = { "Error" => "Free API quota exceeded by more than 50%. Quota will reset tomorrow. Contact SharedCount to inquire about paid plans. http://sharedcount.com/quota",
               "Type" => "quota_exceeded" }
      stub_request(:get, Regexp.new(SharedCountApi::Client::HTTP_ENDPOINT)).
        to_return(body: JSON.generate(body), status: 401, headers: { "X-IP-Quota-Remaining" => 0 })

    end

    it "raises the appropriate error" do
      proc {
        subject.stumble_upon
      }.must_raise SharedCountApi::Error
    end
  end

  describe "when the provided URL is invalid" do
    before do
      body = { "Error" => "Not a valid URL.", "Type" => "invalid_url" }
      stub_request(:get, Regexp.new(SharedCountApi::Client::HTTP_ENDPOINT)).
        to_return(body: JSON.generate(body), status: 400)

    end

    let(:url) { "invalid url" }

    it "raises the appropriate error" do
      proc {
        subject.stumble_upon
      }.must_raise SharedCountApi::Error
    end
  end

  describe "when security is of the utmost importance" do
    subject { SharedCountApi::Client.new(url, true) }
    before do
      stub_request(:get, Regexp.new(SharedCountApi::Client::HTTPS_ENDPOINT)).
        to_return(body: JSON.generate(body))
    end

    it "makes requests over SSL" do
      subject.stumble_upon.must_equal body[:StumbleUpon]
    end
  end

  describe "when the request succeeds" do
    before do
      stub_request(:get, Regexp.new(SharedCountApi::Client::HTTP_ENDPOINT)).
        to_return(body: JSON.generate(body))
    end

    it "includes the number of StumbleUpon shares" do
      subject.stumble_upon.must_equal body[:StumbleUpon]
    end

    it "includes the number of Reddit shares" do
      subject.reddit.must_equal body[:Reddit]
    end

    it "includes the number of Facebook likes" do
      subject.facebook_like_count.must_equal body[:Facebook][:like_count]
    end

    it "includes the number of Facebook shares" do
      subject.facebook_share_count.must_equal body[:Facebook][:share_count]
    end

    it "includes the number of Delicious shares" do
      subject.delicious.must_equal body[:Delicious]
    end

    it "includes the number of Google +1s" do
      subject.google_plus_one.must_equal body[:GooglePlusOne]
    end

    it "includes the number of Buzz shares" do
      subject.buzz.must_equal body[:Buzz]
    end

    it "includes the number of Twitter shares" do
      subject.twitter.must_equal body[:Twitter]
    end

    it "includes the number of Digg shares" do
      subject.diggs.must_equal body[:Diggs]
    end

    it "includes the number of Pinterest shares" do
      subject.pinterest.must_equal body[:Pinterest]
    end

    it "includes the number of LinkedIn shares" do
      subject.linked_in.must_equal body[:LinkedIn]
    end
  end
end

