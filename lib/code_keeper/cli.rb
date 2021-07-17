# frozen_string_literal: true

module CodeKeeper
  # Offers cli interface and execute measurement.
  class Cli
    def self.run(*paths)
      result = {}
      Finder.new(paths).file_paths.each do |path|
        result[path] = CyclomaticComplexity.new(path).score
      end
      result
    end
  end
end
