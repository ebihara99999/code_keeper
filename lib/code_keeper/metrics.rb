# frozen_string_literal: true

require 'code_keeper/metrics/cyclomatic_complexity'

module CodeKeeper
  # Manage config values of metrics and the correspond classes
  module Metrics
    MAPPINGS = { cyclomatic_complexity: CodeKeeper::Metrics::CyclomaticComplexity }.freeze
  end
end
