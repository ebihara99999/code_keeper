# frozen_string_literal: true

module CodeKeeper
  # Find ruby files and manage the list of files.
  class Finder
    attr_reader :file_paths

    def initialize(file_paths)
      @file_paths = file_paths.uniq.map do |path|
        absolute_path = File.expand_path(path)
        next absolute_path if File.exist? absolute_path

        raise TargetFileNotFoundError, "The target file does not exist. Check the file path: #{absolute_path}."
      end
    end
  end
end
