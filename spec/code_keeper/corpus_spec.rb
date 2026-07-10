# frozen_string_literal: true

require "json"
require "spec_helper"
require "support/corpus_report_runner"

RSpec.describe "GitLab corpus verification" do
  describe "vendored corpus" do
    it "contains the approved Ruby file list" do
      expect(Dir[File.join(CorpusReportRunner::ROOT, "**/*.rb")].sort).to eq CorpusReportRunner.file_paths.sort
    end

    it "does not include excluded GitLab license scopes" do
      vendored_paths = Dir[File.join(CorpusReportRunner::ROOT, "**", "*")].select { |path| File.file?(path) }

      expect(vendored_paths.grep(%r{\A#{CorpusReportRunner::ROOT}/(?:ee|jh|doc)/})).to be_empty
    end
  end

  describe "per-file runner" do
    CorpusReportRunner.file_paths.each do |path|
      it "measures #{path} without crashing" do
        expect { CorpusReportRunner.report_for(path, number_of_threads: 1).to_h }.not_to raise_error
      end
    end
  end

  describe "report invariants" do
    it "returns valid report-shaped data for every file" do
      CorpusReportRunner.file_paths.each do |path|
        aggregate_failures path do
          expect_valid_report_shape(CorpusReportRunner.report_for(path, number_of_threads: 1).to_h)
        end
      end
    end

    it "derives every summary from measurements" do
      CorpusReportRunner.file_paths.each do |path|
        report_hash = CorpusReportRunner.report_for(path, number_of_threads: 1).to_h

        aggregate_failures path do
          expect(report_hash.fetch(:summary).fetch(:metrics)).to eq summary_from(report_hash.fetch(:measurements))
        end
      end
    end

    it "keeps ABC and cyclomatic measurement counts aligned" do
      CorpusReportRunner.file_paths.each do |path|
        counts = CorpusReportRunner.report_for(path, number_of_threads: 1).measurements.group_by(&:metric).transform_values(&:size)

        aggregate_failures path do
          expect(counts.fetch(:abc_metric, 0)).to eq counts.fetch(:cyclomatic_complexity, 0)
        end
      end
    end

    it "keeps every measurement line range inside its file" do
      CorpusReportRunner.file_paths.each do |path|
        line_count = File.readlines(path).size
        measurements = CorpusReportRunner.report_for(path, number_of_threads: 1).measurements

        aggregate_failures path do
          measurements.each do |measurement|
            expect_measurement_lines_inside_file(measurement, line_count)
          end
        end
      end
    end

    it "returns identical output with sequential and parallel file runs" do
      sequential_report = CorpusReportRunner.report_for(CorpusReportRunner.file_paths, number_of_threads: 1).to_h
      parallel_report = CorpusReportRunner.report_for(
        CorpusReportRunner.file_paths,
        number_of_threads: CorpusReportRunner::PARALLEL_THREAD_COUNT
      ).to_h

      expect(parallel_report).to eq sequential_report
    end

    it "omits metrics with no measurements from the summary" do
      report_hash = CorpusReportRunner.report_for(
        File.join(CorpusReportRunner::ROOT, "config/routes.rb"),
        number_of_threads: 1
      ).to_h

      expect(report_hash.fetch(:summary).fetch(:metrics)).not_to have_key(:class_length)
    end
  end

  def expect_valid_report_shape(report_hash)
    expect { JSON.generate(report_hash) }.not_to raise_error
    expect_report_root_shape(report_hash)
    expect_summary_shape(report_hash.fetch(:summary).fetch(:metrics))
    expect_measurement_shapes(report_hash.fetch(:measurements))
  end

  def expect_report_root_shape(report_hash)
    expect(report_hash.keys).to contain_exactly(:summary, :measurements)
    expect(report_hash.fetch(:summary).keys).to contain_exactly(:metrics)
    expect(report_hash.fetch(:summary).fetch(:metrics)).to be_a(Hash)
    expect(report_hash.fetch(:measurements)).to be_an(Array)
  end

  def expect_summary_shape(metrics)
    metrics.each do |metric, summary|
      expect_metric_summary_shape(metric, summary)
    end
  end

  def expect_metric_summary_shape(metric, summary)
    expect_metric_summary_identity(metric, summary)
    expect_metric_summary_values(summary)
    expect_measurement_shapes(summary.fetch(:top_hotspots))
  end

  def expect_metric_summary_identity(metric, summary)
    expect(CodeKeeper::Metrics::MAPPINGS).to include(metric)
    expect(summary.keys).to contain_exactly(:count, :max, :top_hotspots)
  end

  def expect_metric_summary_values(summary)
    expect(summary.fetch(:count)).to be_a(Integer)
    expect(summary.fetch(:count)).to be_positive
    expect(summary.fetch(:max)).to be_a(Numeric)
    expect(summary.fetch(:top_hotspots)).to be_an(Array)
    expect(summary.fetch(:top_hotspots).size).to be <= CodeKeeper::MetricReport::TOP_HOTSPOTS_LIMIT
  end

  def expect_measurement_shapes(measurements)
    measurements.each do |measurement|
      expect_measurement_shape(measurement)
    end
  end

  def expect_measurement_shape(measurement)
    expect_measurement_identity_shape(measurement)
    expect_measurement_location_shape(measurement)
    expect(measurement.fetch(:value)).to be_a(Numeric)
  end

  def expect_measurement_identity_shape(measurement)
    expect(measurement.keys).to contain_exactly(:metric, :scope_type, :scope_name, :path, :start_line, :end_line, :value)
    expect(CodeKeeper::Metrics::MAPPINGS).to include(measurement.fetch(:metric))
    expect(%i[class method module singleton_class]).to include(measurement.fetch(:scope_type))
    expect(measurement.fetch(:scope_name)).to be_a(String)
  end

  def expect_measurement_location_shape(measurement)
    expect(measurement.fetch(:path)).to be_a(String)
    expect(measurement.fetch(:start_line)).to be_a(Integer)
    expect(measurement.fetch(:end_line)).to be_a(Integer)
  end

  def summary_from(measurements)
    measurements.group_by { |measurement| measurement.fetch(:metric) }.transform_values do |group|
      {
        count: group.size,
        max: group.map { |measurement| measurement.fetch(:value) }.max,
        top_hotspots: top_hotspots_from(group)
      }
    end
  end

  def top_hotspots_from(measurements)
    measurements
      .sort_by { |measurement| [-measurement.fetch(:value), measurement.fetch(:path), measurement.fetch(:start_line), measurement.fetch(:scope_name)] }
      .first(CodeKeeper::MetricReport::TOP_HOTSPOTS_LIMIT)
  end

  def expect_measurement_lines_inside_file(measurement, line_count)
    expect(measurement.start_line).to be_between(1, line_count)
    expect(measurement.end_line).to be_between(measurement.start_line, line_count)
  end
end
