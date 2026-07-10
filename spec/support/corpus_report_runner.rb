# frozen_string_literal: true

# Runs CodeKeeper against the vendored GitLab corpus with explicit settings.
module CorpusReportRunner
  ROOT = "spec/fixtures/corpus/gitlab"
  PARALLEL_THREAD_COUNT = 4
  RELATIVE_PATHS = %w[
    app/models/project.rb
    app/models/merge_request.rb
    app/models/concerns/has_repository.rb
    app/services/merge_requests/create_service.rb
    app/services/ci/create_pipeline_service.rb
    app/graphql/types/project_type.rb
    app/policies/project_policy.rb
    lib/gitlab/ci/config/entry/job.rb
    lib/gitlab/ci/config/entry/rules.rb
    lib/gitlab/ci/pipeline/chain/validate/abilities.rb
    lib/gitlab/background_migration/backfill_award_emoji_sharding_key.rb
    lib/gitlab/database/migrations/runner_backoff/communicator.rb
    config/routes.rb
    app/models/ability.rb
    app/models/concerns/issuable.rb
    app/models/release_highlight.rb
    app/models/concerns/ignorable_columns.rb
    app/models/concerns/from_set_operator.rb
    app/models/concerns/ci/partitionable.rb
    spec/models/ability_spec.rb
  ].freeze
  FILE_PATHS = RELATIVE_PATHS.map { |path| File.join(ROOT, path) }.freeze

  module_function

  def file_paths
    FILE_PATHS
  end

  def report_for(paths, number_of_threads:)
    CodeKeeper.configure do |config|
      config.metrics = CodeKeeper::Metrics::MAPPINGS.keys
      config.number_of_threads = number_of_threads
    end

    CodeKeeper::Scorer.keep(Array(paths))
  end
end
