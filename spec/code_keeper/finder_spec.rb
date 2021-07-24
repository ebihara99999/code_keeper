# frozen_string_literal: true

RSpec.describe CodeKeeper::Finder do
  let(:duplicated_relative_paths) { ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb'] }
  let(:relative_paths_including_unexisted) { ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/not_existed.rb'] }
  let(:absolute_and_unique_paths) { [File.expand_path('./spec/fixtures/branch_in_loop.rb'), File.expand_path('./spec/fixtures/target_sample.rb')] }

  it 'stores absolute paths and remove dupulicated one' do
    finder = CodeKeeper::Finder.new(duplicated_relative_paths)
    expect(finder.file_paths).to match_array(absolute_and_unique_paths)
  end

  context 'the argument has unexisted path' do
    it 'raises CodeKeeper::TargetFileNotFoundError' do
      expect { CodeKeeper::Finder.new(relative_paths_including_unexisted) }.to raise_error CodeKeeper::TargetFileNotFoundError
    end
  end

  context 'the argument includes a path to a flat directory' do
  end

  context 'the argument includes a path to a nested directory' do
  end

  context 'the argument includes two different directories' do
  end

  context 'the argument includes a parent directory and the sub directory' do
  end

  context 'the argument includes a directory and a file' do
  end
end
