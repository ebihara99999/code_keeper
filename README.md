# CodeKeeper
CodeKeeper emits Ruby code metric snapshots for periodic code quality reviews.

It is not a RuboCop replacement. RuboCop is excellent at reporting style and metric offenses, but offense reporting is intentionally configurable: projects can disable cops, exclude files, allow specific methods, or relax thresholds. CodeKeeper is built for a different job. It keeps measuring metric values even when RuboCop offense reporting has been silenced or loosened.

The intended use is recurring code quality review. Run CodeKeeper, hand the structured snapshot to a human or AI agent, and use the metric values as review signals.

## Design

CodeKeeper uses RuboCop as a Ruby analysis foundation, not as an offense policy engine.

- Ruby parsing is based on `RuboCop::AST::ProcessedSource`.
- Standard metric values are calculated through RuboCop metric calculators or RuboCop metric cop behavior behind CodeKeeper adapters.
- RuboCop project configuration is not applied to measurement.

CodeKeeper does not read `.rubocop.yml`, `rubocop:disable`, `Max`, `AllowedMethods`, `AllowedPatterns`, or `Exclude`. Those settings control RuboCop offense reporting, but CodeKeeper's purpose is to keep the underlying measurements visible.

Each metric is measured at its natural scope:

- `abc_metric`: method, singleton method, and `define_method` block.
- `cyclomatic_complexity`: method, singleton method, and `define_method` block.
- `class_length`: class, module, singleton class, and class-like constant assignment.

File paths are included as location data, but files are not the primary measurement scope. If you need file-level grouping, build it from the `measurements` array or ask an AI agent to group hotspots by file, directory, domain, or owner.

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
Run CodeKeeper and you get a metric snapshot from stdout.

```rb
$ bundle exec code_keeper app/models/user.rb app/models/admin.rb > metrics.json
$ cat metrics.json
{
  "summary": {
    "metrics": {
      "abc_metric": {
        "count": 2,
        "max": 18.2,
        "top_hotspots": [
          {
            "metric": "abc_metric",
            "scope_type": "method",
            "scope_name": "User#save!",
            "path": "app/models/user.rb",
            "start_line": 42,
            "end_line": 80,
            "value": 18.2
          }
        ]
      }
    }
  },
  "measurements": [
    {
      "metric": "abc_metric",
      "scope_type": "method",
      "scope_name": "User#save!",
      "path": "app/models/user.rb",
      "start_line": 42,
      "end_line": 80,
      "value": 18.2
    }
  ]
}
```

The `summary` section is intended for quick review. The `measurements` section contains the metric-native values that support deeper analysis.

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
  # The default engine uses RuboCop-standard metric definitions through CodeKeeper adapters.
  config.metrics_engine = :rubocop_standard
  # The default is json
  config.format = :json
end
```

### Output formats

The default `json` format returns the new snapshot schema.

```rb
CodeKeeper.configure do |config|
  config.format = :json
end
```

For existing integrations, legacy formats remain available.

```rb
CodeKeeper.configure do |config|
  config.metrics_engine = :legacy
  config.format = :legacy_json
end
```

`config.format = :csv` keeps the existing CSV format. `config.format = :legacy_csv` is an explicit alias for that behavior.

The legacy engine keeps historical CodeKeeper behavior for migration. New integrations should use the default `:rubocop_standard` engine.

## Using CodeKeeper with AI review workflows

CodeKeeper is designed to provide structured metric data for recurring AI-assisted reviews. A typical workflow is:

1. Run CodeKeeper on the target codebase.
2. Save the JSON snapshot.
3. Ask an AI agent to analyze hotspots, group measurements by file, directory, domain, or owner, and suggest focused refactoring candidates.
4. Use the metrics as review signals, not as automatic pass/fail thresholds.

Example prompt:

```text
Analyze this CodeKeeper JSON snapshot.

Focus on:
- the highest ABC and cyclomatic complexity measurements
- classes or modules with unusually large length
- files or domains that contain multiple hotspots
- refactoring candidates that reduce risk without broad rewrites

Do not treat these metrics as hard pass/fail thresholds.
Use them as signals for code quality review.
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
