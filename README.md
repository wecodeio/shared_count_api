# SharedCountApi

Thin wrapper around the SharedCount API in vanilla Ruby

## Installation

Add this line to your application's Gemfile:

    gem 'shared_count_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shared_count_api

## Usage

```ruby
require "shared_count_api"

SharedCountApi.configure do |config|
  config.apikey = 'my-api-key'
  config.url = 'my-dedicated-url'  # only use if you have a dedicated url plan
end

client = SharedCountApi::Client.new("http://slashdot.org")
client.twitter # => 24381
client.facebook_share_count # => 2705
client.google_plus_one # => 16633
# you get the drill ;)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
