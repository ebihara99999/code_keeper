# frozen_string_literal: true

require 'json'

module CodeKeeper
  # Formats a metric report for output.
  class Formatter
    class << self
      def format(metric_report)
        metric_report.to_h.to_json
      end
    end
  end
end
