# frozen_string_literal: true

module CodeKeeper
  # Run and store score of metrics.
  class Scorer
    class << self
      def keep(paths)
        result = CodeKeeper::Result.new
        metrics = result.scores.keys

        Finder.new(paths).file_paths.each do |path|
          metrics.each do |metric|
            result.add(:cyclomatic_complexity, path, ::CodeKeeper::Metrics::MAPPINGS[metric].new(path).score)
          end
        end

        result
      end
    end
  end
end
