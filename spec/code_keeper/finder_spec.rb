# frozen_string_literal: true

RSpec.describe CodeKeeper::Finder do
  context 'the argument includes files one of which is dupulicated' do
    before do
      @duplicated_relative_paths = ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/branch_in_loop.rb', './spec/fixtures/target_sample.rb']
    end

    it 'stores paths and remove dupulicated one' do
      expected_paths = [
        './spec/fixtures/branch_in_loop.rb',
        './spec/fixtures/target_sample.rb'
      ]

      finder = CodeKeeper::Finder.new(@duplicated_relative_paths)
      expect(finder.file_paths).to match_array(expected_paths)
    end
  end

  context 'the argument has unexisted path' do
    before do
      @relative_paths_including_unexisted = ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/not_existed.rb']
    end

    it 'raises CodeKeeper::TargetFileNotFoundError' do
      expect { CodeKeeper::Finder.new(@relative_paths_including_unexisted) }.to raise_error(::CodeKeeper::TargetFileNotFoundError)
    end
  end

  context 'the argument includes a path to a flat directory' do
    before do
      @relative_paths = ['./spec/fixtures/flat_dir']
    end

    it 'stores relative paths' do
      expected_paths = [
        './spec/fixtures/flat_dir/a.rb',
        './spec/fixtures/flat_dir/b.rb'
      ]

      finder = CodeKeeper::Finder.new(@relative_paths)
      expect(finder.file_paths).to match_array(expected_paths)
    end
  end

  context 'the argument includes a path to a nested directory' do
    before do
      @relative_paths = ['./spec/fixtures/nested_dir']
    end

    it 'stores relative paths' do
      expected_paths = [
        './spec/fixtures/nested_dir/sub_dir/a.rb',
        './spec/fixtures/nested_dir/a.rb'
      ]

      finder = CodeKeeper::Finder.new(@relative_paths)
      expect(finder.file_paths).to match_array(expected_paths)
    end
  end

  context 'the argument includes two different directories' do
    before do
      @relative_paths = ['./spec/fixtures/nested_dir', './spec/fixtures/flat_dir']
    end

    it 'stores relative paths' do
      expected_paths = [
        './spec/fixtures/flat_dir/a.rb',
        './spec/fixtures/flat_dir/b.rb',
        './spec/fixtures/nested_dir/sub_dir/a.rb',
        './spec/fixtures/nested_dir/a.rb'
      ]

      finder = CodeKeeper::Finder.new(@relative_paths)
      expect(finder.file_paths).to match_array(expected_paths)
    end
  end

  context 'the argument includes a parent directory and the sub directory' do
    before do
      @relative_paths = ['./spec/fixtures/nested_dir', './spec/fixtures/nested_dir/sub_dir']
    end

    it 'stores relative paths' do
      expected_paths = [
        './spec/fixtures/nested_dir/sub_dir/a.rb',
        './spec/fixtures/nested_dir/a.rb'
      ]

      finder = CodeKeeper::Finder.new(@relative_paths)
      expect(finder.file_paths).to match_array(expected_paths)
    end
  end

  context 'the argument includes a directory and a file' do
    before do
      @relative_paths = ['./spec/fixtures/branch_in_loop.rb', './spec/fixtures/flat_dir']
    end

    it 'stores relative paths' do
      expected_paths = [
        './spec/fixtures/flat_dir/a.rb',
        './spec/fixtures/flat_dir/b.rb',
        './spec/fixtures/branch_in_loop.rb'
      ]

      finder = CodeKeeper::Finder.new(@relative_paths)
      expect(finder.file_paths).to match_array(expected_paths)
    end
  end
end
