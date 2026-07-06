# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

namespace :corpus do
  desc "Regenerate committed golden reports for the vendored GitLab corpus"
  task :regenerate_golden_reports do
    require_relative "lib/code_keeper"
    require_relative "spec/support/corpus_report_runner"
    require_relative "spec/support/corpus_golden_report"

    CorpusGoldenReport.regenerate_all
  end
end

task default: %i[spec rubocop]
