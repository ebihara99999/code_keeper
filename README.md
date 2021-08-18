# CodeKeeper
The CodeKeeper measures metrics especially about complexity and size of Ruby files, aiming to be a Ruby version of [gmetrics](https://github.com/dx42/gmetrics)

Mesuring metrics leads to keep codebase simple and clean, and I name the gem CodeKeeper.

Now CodeKeeper supports the cyclomatic complexity. The scores are output to stdout.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'code_keeper'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install code_keeper

## Usage
Run CodeKeeper and you get scores of metrics from stdout like 

```rb
$ bundle exec code_keeper ./app/models
Scores:

Metric: cyclomatic_complexity
Filename: app/models/admin.rb
Score: 1
---
Metric: cyclomatic_complexity
Filename: app/models/user.rb
Score: 23
---
```

### Run CodeKeeper
To measure metrics of all the ruby files recursively in the current directory, run

```rb
$ bundle exec code_keeper ./
```

You can specify a single file or multiple files. 
```rb
$ bundle exec code_keeper ./dir/a.rb ./dir/b.rb
```

CodeKeeper makes you configure the following way:

```rb
CodeKeeper.configure do |config|
  # If you choose metrics, specify as follows:
  config.metrics = [:cyclomatic_complexity]
  # The number of threads. The default is 2. Executed sequentially if you set 1.
  config.number_of_threads = 4
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ebihara99999/code_keeper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ebihara99999/code_keeper/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CodeKeeper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ebihara99999/code_keeper/blob/master/CODE_OF_CONDUCT.md).
