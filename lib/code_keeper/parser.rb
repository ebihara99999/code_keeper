# frozen_string_literal: true

module CodeKeeper
  # Search and parse ruby file
  class Parser
    attr_reader :processed_source

    def initialize(file_path)
      @source_file = SourceFile.new(file_path)
      @processed_source = @source_file.processed_source
    end

    class << self
      def parse(file_path)
        parser = new(file_path)
        parser.processed_source
      end

      def source_file(file_path)
        SourceFile.new(file_path)
      end
    end
  end
end
