# frozen_string_literal: true

require 'csv'
require 'json'

module CodeKeeper
  # Format a result and make it human-readable.
  class Formatter
    class << self
      def format(result)
        case CodeKeeper.config.format
        when :json
          result.metric_report.to_h.to_json
        when :csv
          csv(result)
        end
      end

      private

      def csv(result)
        csv_array = []
        result.scores.each_key do |metric|
          result.scores[metric].each { |k, v| csv_array << [metric, k, v] }
        end

        headers = %w[metric file score]
        CSV.generate(headers: true) do |csv|
          csv << headers
          csv_array.each { |array| csv << array }
        end
      end
    end
  end
end
