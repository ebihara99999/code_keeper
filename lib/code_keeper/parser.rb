# frozen_string_literal: true
module CodeKeeper
  # Search and parse ruby file
  class Parser
    attr_reader :processed_source

    def initialize(file_path)
      source = File.read(File.expand_path(file_path))
      @processed_source = ::RuboCop::AST::ProcessedSource.new(source, 3.0)
    rescue Errno::ENOENT
      raise TargetFileNotFoundError, "The target file does not exist. Check the file path: #{file_path}."
    end

    class << self
      def parse(file_path)
        parser = new(file_path)
        parser.processed_source
      end
    end
  end
end
