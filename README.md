# Memo::It

Clever memoization helper that uses Ruby internals instead of meta-programming. [![Build Status](https://travis-ci.org/phoet/memo-it.svg?branch=master)](https://travis-ci.org/phoet/memo-it)

## Using Memo::It

### Basic Usage

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

### Instance vs Class memoization

Per default, the memoization will be done on an instance level,
so every instance of an object will have it's own memoization namespace:

```ruby
  class Loader
    def initialize(url)
      @url = url
    end

    def content
      memo do
        # fetch the url content from the web
      end
    end
  end

  issues_loader = Loader.new('https://github.com/phoet/memo-it/issues')
  pulls_loader  = Loader.new('https://github.com/phoet/memo-it/pulls')

  issues_loader.content # load & memoize the issues
  pulls_loader.content # load & memoize the pulls
```

But you can also memoize on a global/class scope.
This is needed if you want to use Memo::It in dynamically instanciated objects like Rails helpers:

```ruby
  module WebHelper
    def content(url)
      Memo::It.memo do
        # fetch the url content from the web
      end
    end
  end
```

### Parameters as scopes

In case you want to memoize something that has parameters, Memo::It will just use all local variables in scope to determine the memoization:

```ruby
  def load_repo(name = 'memo-it')
    memo do
      # in this case the result will be memoized per name
      HTTPClient.get("https://github.com/phoet/#{name}")
    end
  end
```

If, on the other hand, you want to memoize parameters but ignore one of them,
you can do this by adding it to the `:except` list:

```ruby
  def load_repo(name = 'memo-it', time = Time.now)
    memo(except: :time) do
      # in this case the result will be memoized per name
      HTTPClient.get("https://github.com/phoet/#{name}?time=#{time}")
    end
  end
```

Or provide a list of parameters to except:

```ruby
  def load_repo(name = 'memo-it', time = Time.now, other = 'irrelevant')
    memo(except: [:time, :other]) do
      # in this case the result will be memoized per name
      HTTPClient.get("https://github.com/phoet/#{name}?time=#{time}&other=#{other}")
    end
  end
```

To be symmetric, it's also possible to define one or more parameters through the `:only` key:

```ruby
  def load_repo(name = 'memo-it', time = Time.now, format = 'json')
    memo(only: [:name, :format]) do
      # in this case the result will be memoized per name & format
      HTTPClient.get("https://github.com/phoet/#{name}?time=#{time}&format=#{format}")
    end
  end
```

Provide your own memoization keys through the `:provided` key:

```ruby
  def load_repo(name = 'memo-it')
    memo(provided: Date.today.day_of_week) do
      # in this case the result will be memoized per name and day_of_week
      HTTPClient.get("https://github.com/phoet/#{name}")
    end
  end
```

### Turning it on and off

In case you would like to disable memoization (ie. for testing) you can disable Memo::It:

```ruby
  # enabled is default
  Memo.enabled? # => true

  # disable memoization globally
  Memo.disable
  Memo.enabled? # => false

  # re-enable memoization
  Memo.enable
  Memo.enabled? # => true
```

## Caveats

### Multiple calls to memo on the same line of code

If you want to call `memo` twice within the same line of code, you would need provide a custom key through the `:provided` argument.
This is not recommended through. A better alternative would be to put both calls into their own sub-methods and call those instead.

### Runtime-Speed

Compared to other memoization frameworks, the `memo` method requires more computation and is slower by size of a magnitude: https://github.com/phoet/memo-it/issues/6
Do not use this library to optimize hot code-paths! Use it to cache really slow things such as network-requests or generation of large strings like JSON objects etc.
Whatever you do, benchmark your code in order to see if the memoization strategy you use is a good fit for your use-case.

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

## Changelog

See [CHANGELOG.md](https://github.com/phoet/memo-it/blob/master/CHANGELOG.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/phoet/memo-it. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
