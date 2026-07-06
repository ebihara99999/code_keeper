# frozen_string_literal: true

require "spec_helper"
require "support/corpus_report_runner"
require "support/corpus_golden_report"

RSpec.describe "GitLab corpus golden reports" do
  it "has one snapshot per corpus file" do
    expect(Dir[File.join(CorpusGoldenReport::ROOT, "**/*.json")].sort).to eq CorpusGoldenReport.snapshot_paths.sort
  end

  it "matches the current CodeKeeper report for every corpus file" do
    CorpusReportRunner.file_paths.each do |path|
      aggregate_failures path do
        expect(File.read(CorpusGoldenReport.snapshot_path_for(path))).to eq CorpusGoldenReport.serialized_report_for(path)
      end
    end
  end

  it "stores repository-relative paths in snapshots" do
    paths = CorpusGoldenReport.snapshot_paths.flat_map do |snapshot_path|
      paths_in(JSON.parse(File.read(snapshot_path)))
    end

    expect(paths).to all(match(%r{\Aspec/fixtures/corpus/gitlab/}))
  end

  it "detects stale snapshots outside the corpus file list" do
    stale_path = File.join(CorpusGoldenReport::ROOT, "obsolete.rb.json")
    existing_paths = CorpusGoldenReport.snapshot_paths + [stale_path]

    expect(CorpusGoldenReport.stale_snapshot_paths(existing_paths: existing_paths)).to eq [stale_path]
  end

  def paths_in(value)
    case value
    when Array
      value.flat_map { |item| paths_in(item) }
    when Hash
      value.flat_map { |key, item| key == "path" ? [item] : paths_in(item) }
    else
      []
    end
  end
end
