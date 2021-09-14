# frozen_string_literal: true

require 'csv'

module CodeKeeper
  # Format a result and make it human-readable.
  class Formatter
    class << self
      def format(result)
        return result.scores.to_json if CodeKeeper.config.format == :json

        # csv is supported besides json
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
