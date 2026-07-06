# frozen_string_literal: true

require "fileutils"
require "json"

# Generates and locates committed CodeKeeper JSON reports for the corpus.
module CorpusGoldenReport
  ROOT = "spec/fixtures/golden_reports/gitlab"

  module_function

  def snapshot_paths
    CorpusReportRunner.file_paths.map { |path| snapshot_path_for(path) }
  end

  def snapshot_path_for(corpus_path)
    relative_path = corpus_path.delete_prefix("#{CorpusReportRunner::ROOT}/")

    File.join(ROOT, "#{relative_path}.json")
  end

  def serialized_report_for(corpus_path)
    "#{JSON.pretty_generate(report_hash_for(corpus_path))}\n"
  end

  def regenerate_all
    prune_stale_snapshots

    CorpusReportRunner.file_paths.each do |corpus_path|
      snapshot_path = snapshot_path_for(corpus_path)
      FileUtils.mkdir_p(File.dirname(snapshot_path))
      File.write(snapshot_path, serialized_report_for(corpus_path))
    end
  end

  def prune_stale_snapshots
    FileUtils.rm_f(stale_snapshot_paths)
  end

  def stale_snapshot_paths(existing_paths: Dir[File.join(ROOT, "**/*.json")])
    existing_paths - snapshot_paths
  end

  def report_hash_for(corpus_path)
    CorpusReportRunner.report_for(corpus_path, number_of_threads: 1).to_h
  end
end
