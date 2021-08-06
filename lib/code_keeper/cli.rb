# frozen_string_literal: true

module CodeKeeper
  # Offers cli interface and execute measurement.
  class Cli
    SUCCESS_CODE = 0
    GENERAL_ERROR_CODE = 1
    ERROR_CODE = 2
    INTERRUPTION_CODE = 128 + Signal.list['INT']

    def self.run(paths)
      result = {}
      Finder.new(paths).file_paths.each do |path|
        result[path] = CyclomaticComplexity.new(path).score
      end

      puts ::CodeKeeper::Formatter.format(result)
      SUCCESS_CODE
    rescue Interrupt
      puts 'Exiting...'
      INTERRUPTION_CODE
    rescue CodeKeeper::TargetFileNotFoundError => e
      puts e.message
      ERROR_CODE
    rescue StandardError => e
      puts e.message
      GENERAL_ERROR_CODE
    end
  end
end
