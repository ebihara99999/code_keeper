# frozen_string_literal: true

module CodeKeeper
  # A metric value measured at the metric's natural source scope.
  class Measurement
    attr_reader :metric, :scope_type, :scope_name, :path, :start_line, :end_line, :value

    def initialize(attributes)
      @metric = attributes.fetch(:metric).to_sym
      @scope_type = attributes.fetch(:scope_type).to_sym
      @scope_name = attributes.fetch(:scope_name).to_s
      @path = attributes.fetch(:path)
      @start_line = attributes.fetch(:start_line)
      @end_line = attributes.fetch(:end_line)
      @value = attributes.fetch(:value)
    end

    def legacy_key
      return scope_name if %i[class module singleton_class].include?(scope_type)

      "#{path}:#{scope_name}"
    end

    def to_h
      {
        metric: metric,
        scope_type: scope_type,
        scope_name: scope_name,
        path: path,
        start_line: start_line,
        end_line: end_line,
        value: value
      }
    end
  end
end
