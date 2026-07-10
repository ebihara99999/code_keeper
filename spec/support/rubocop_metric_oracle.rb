# frozen_string_literal: true

# Runs RuboCop metric cops through the normal cop pipeline and captures raw
# metric values before offense messages round them for display.
module RuboCopMetricOracle
  TARGET_RUBY_VERSION = RUBY_VERSION.split(".").first(2).join(".").to_f

  Measurement = Struct.new(:metric, :path, :start_line, :end_line, :value, keyword_init: true) do
    def key
      [metric, path, start_line]
    end

    def to_h
      {
        metric: metric,
        path: path,
        start_line: start_line,
        end_line: end_line,
        value: value
      }
    end
  end

  # Keeps wrapper cops tied to the original RuboCop cop config and badge.
  module CopIdentity
    def cop_name
      rubocop_cop_name
    end

    def badge
      RuboCop::Cop::Badge.parse(rubocop_cop_name)
    end
  end

  # Stores raw metric measurements observed during one RuboCop investigation.
  module CapturesMeasurements
    attr_reader :measurements

    def on_new_investigation
      super
      @measurements = []
    end

    private

    def capture_measurement(metric, node, value)
      measurements << Measurement.new(
        metric: metric,
        path: processed_source.file_path,
        start_line: node.first_line,
        end_line: node.last_line,
        value: value
      )
    end
  end

  # Captures ABC values before RuboCop formats an offense message.
  class CapturedAbcSize < RuboCop::Cop::Metrics::AbcSize
    extend CopIdentity
    include CapturesMeasurements
    exclude_from_registry

    def self.rubocop_cop_name
      "Metrics/AbcSize"
    end

    private

    def check_complexity(node, method_name)
      unless node.body
        capture_measurement(:abc_metric, node, 0)
        return
      end

      reset_repeated_csend
      value, = complexity(node.body)
      capture_measurement(:abc_metric, node, value)
      super
    end
  end

  # Captures cyclomatic complexity values before offense reporting.
  class CapturedCyclomaticComplexity < RuboCop::Cop::Metrics::CyclomaticComplexity
    extend CopIdentity
    include CapturesMeasurements
    exclude_from_registry

    def self.rubocop_cop_name
      "Metrics/CyclomaticComplexity"
    end

    private

    def check_complexity(node, method_name)
      unless node.body
        capture_measurement(:cyclomatic_complexity, node, 1)
        return
      end

      reset_repeated_csend
      capture_measurement(:cyclomatic_complexity, node, complexity(node.body))
      super
    end
  end

  # Captures class length values before offense reporting.
  class CapturedClassLength < RuboCop::Cop::Metrics::ClassLength
    extend CopIdentity
    include CapturesMeasurements
    exclude_from_registry

    def self.rubocop_cop_name
      "Metrics/ClassLength"
    end

    private

    def check_code_length(node)
      capture_measurement(:class_length, node, build_code_length_calculator(node).calculate)
      super
    end
  end

  # CodeKeeper's class_length metric covers modules too, so the RuboCop oracle
  # needs ModuleLength in addition to ClassLength for that shared measurement.
  class CapturedModuleLength < RuboCop::Cop::Metrics::ModuleLength
    extend CopIdentity
    include CapturesMeasurements
    exclude_from_registry

    def self.rubocop_cop_name
      "Metrics/ModuleLength"
    end

    private

    def check_code_length(node)
      capture_measurement(:class_length, node, build_code_length_calculator(node).calculate)
      super
    end
  end

  COP_CLASSES = [
    CapturedAbcSize,
    CapturedCyclomaticComplexity,
    CapturedClassLength,
    CapturedModuleLength
  ].freeze

  module_function

  def measurements_for(path)
    processed_source = RuboCop::AST::ProcessedSource.new(File.read(path), TARGET_RUBY_VERSION, path)
    team = RuboCop::Cop::Team.mobilize(COP_CLASSES, config, team_options)
    report = team.investigate(processed_source)
    raise report.errors.map(&:message).join("\n") unless report.errors.empty?

    team.cops.flat_map(&:measurements)
  end

  def config
    @config ||= RuboCop::Config.new(
      {
        "AllCops" => {
          "NewCops" => "disable",
          "TargetRubyVersion" => TARGET_RUBY_VERSION
        },
        "Metrics/AbcSize" => {
          "Enabled" => true,
          "Max" => 0,
          "CountRepeatedAttributes" => true,
          "AllowedMethods" => [],
          "AllowedPatterns" => []
        },
        "Metrics/CyclomaticComplexity" => {
          "Enabled" => true,
          "Max" => 0,
          "AllowedMethods" => [],
          "AllowedPatterns" => []
        },
        "Metrics/ClassLength" => {
          "Enabled" => true,
          "Max" => 0,
          "CountComments" => false,
          "CountAsOne" => []
        },
        "Metrics/ModuleLength" => {
          "Enabled" => true,
          "Max" => 0,
          "CountComments" => false,
          "CountAsOne" => []
        }
      },
      nil
    )
  end

  def team_options
    {
      autocorrect: false,
      debug: false,
      ignore_disable_comments: true,
      raise_error: true
    }
  end
end
