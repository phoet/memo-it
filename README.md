# Memo::It

Clever memoization helper that uses Ruby internals instead of meta-programming. [![Build Status](https://travis-ci.org/phoet/memo-it.svg?branch=master)](https://travis-ci.org/phoet/memo-it)

## Usage

Requiring the gem will add a `memo` method to the `Object` class so that you can just use it like so:

```ruby
  def load_stuff_from_the_web
    memo do
      # some expensive operation like HTTP request
      # the return value of the block will be memoized
      HTTPClient.get('https://github.com/phoet/memo-it')
    end
  end
```

In case you want to memoize something that has parameters, memo-it will just use all local variables in scope to determine the memoization:

```ruby
  def load_repo(name =  'memo-it')
    memo do
      # in this case the result will be memoized per name
      HTTPClient.get("https://github.com/phoet/#{name}")
    end
  end
```

If, on the other hand, you want to memoize parameters but ignore one of them,
you can do this by adding it to the `:ignore` list:

```ruby
  def load_repo(name =  'memo-it', time = Time.now)
    memo(ignore: :time) do
      # in this case the result will be memoized per name
      HTTPClient.get("https://github.com/phoet/#{name}?time=#{time}")
    end
  end
```

Or provide a list of parameters to ignore:

```ruby
  def load_repo(name =  'memo-it', time = Time.now, other = 'irrelevant')
    memo(ignore: [:time, :other]) do
      # in this case the result will be memoized per name
      HTTPClient.get("https://github.com/phoet/#{name}?time=#{time}&other=#{other}")
    end
  end
```

To be symmetric, it's also possible to define one or more parameters through the `:only` key:

```ruby
  def load_repo(name =  'memo-it', time = Time.now, format = 'json')
    memo(only: [:name, :format]) do
      # in this case the result will be memoized per name & format
      HTTPClient.get("https://github.com/phoet/#{name}?time=#{time}&format=#{format}")
    end
  end
```

## Installation

### As a Gem

Add this line to your application's Gemfile:

```ruby
gem 'memo-it'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memo-it

### Copy & Paste

If you don't want to include yet another Gem, just run this in your shell:

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/phoet/memo-it/master/bin/install)"

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/memo-it. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
