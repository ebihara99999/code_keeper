# frozen_string_literal: true

RSpec.describe CodeKeeper::Finder do
  let(:duplicated_relative_paths) { ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb'] }
  let(:relative_paths_including_unexisted) { ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/not_existed.rb'] }
  let(:absolute_and_unique_paths) { [File.expand_path('./spec/fixtures/branch_in_loop.rb'), File.expand_path('./spec/fixtures/target_sample.rb')] }

  it 'stores absolute paths and remove dupulicated one' do
    finder = CodeKeeper::Finder.new(duplicated_relative_paths)
    expect(finder.file_paths).to match_array(absolute_and_unique_paths)
  end

  context 'the argument has unexisted_path'
  it 'raises CodeKeeper::TargetFileNotFoundError' do
    expect { CodeKeeper::Finder.new(relative_paths_including_unexisted) }.to raise_error CodeKeeper::TargetFileNotFoundError
  end

  # TODO: It needs to store results, which has keys as file names and values as points
end
