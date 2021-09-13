# frozen_string_literal: true

require 'code_keeper/metrics/abc_metric'
require 'code_keeper/metrics/cyclomatic_complexity'
require 'code_keeper/metrics/class_length'

module CodeKeeper
  # Manage config values of metrics and the correspond classes
  module Metrics
    MAPPINGS = {
      abc_metric: CodeKeeper::Metrics::AbcMetric,
      cyclomatic_complexity: CodeKeeper::Metrics::CyclomaticComplexity,
      class_length: CodeKeeper::Metrics::ClassLength
    }.freeze
  end
end
