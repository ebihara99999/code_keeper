# CodeKeeper
The CodeKeeper measures metrics especially about complexity and size of Ruby files, aiming to be a Ruby version of [gmetrics](https://github.com/dx42/gmetrics)

Mesuring metrics leads to keep codebase simple and clean, and I name the gem CodeKeeper.

Now CodeKeeper supports the cyclomatic complexity of a file, the ABC software metric of a file, and class length. The scores are output to stdout of a json or csv format.

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
$ bundle exec code_keeper app/models/user.rb app/models/admin.rb > metrics.json
$ cat metrics.json
{"cyclomatic_complexity":{"app/models/admin.rb":9,"app/models/user.rb":23},"class_length":{"Admin":86,"User":1475},"abc_metric":{"app/models/admin.rb":76.909,"app/models/user.rb":1546.4155}}
```
If you need a csv format, change the configuration as explained later.

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
  config.metrics = %i(cyclomatic_complexity abc_metric class_length)
  # The number of threads. The default is 2. Executed sequentially if you set 1.
  config.number_of_threads = 4
  # The default is json
  config.format = :json
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
