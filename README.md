# Jbcn

Jbcn is a client for [Jobcan](http://jobcan.ne.jp).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jbcn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jbcn

## Usage

```
require "jbcn"

client = Jbcn::Client.new
client.authenticate(code: "your code goes here")

# Clock in/out
client.clock(:in, group_id: "1")
p client.clock(:out, group_id: "1")
# => {"result"=>1, "state"=>"4", "current_status"=>"returned_home"}

# Clock in with extra info
client.clock(:in, group_id: "1", note: "my first night shift", night_shift: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uasi/jbcn.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
