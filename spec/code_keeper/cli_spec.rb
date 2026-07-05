# frozen_string_literal: true

require 'stringio'

RSpec.describe CodeKeeper::Cli do
  def run_silently(paths)
    original_stdout = $stdout
    $stdout = StringIO.new
    CodeKeeper::Cli.run(paths)
  ensure
    $stdout = original_stdout
  end

  describe '.run' do
    before do
      CodeKeeper.configure do |config|
        config.metrics = [:cyclomatic_complexity]
      end
    end

    context 'normal cases' do
      it 'outputs metric report to stdout' do
        expect do
          CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        end.to output(/"summary"/).to_stdout
      end

      it 'returns 0' do
        expect(run_silently(['./spec/fixtures/branch_in_loop.rb'])).to eq 0
      end
    end

    context 'No argument is specified' do
      it 'returns 2' do
        expect(run_silently([])).to eq 2
      end

      it 'outputs an error message' do
        expected_output = "Specify at least one argument, a file or a directory.\n"
        expect do
          CodeKeeper::Cli.run([])
        end.to output(expected_output).to_stdout
      end
    end

    context 'CodeKeeper::TargetFileNotFoundError is raised' do
      before do
        allow(CodeKeeper::Finder).to receive(:new).and_raise CodeKeeper::TargetFileNotFoundError.new('./spec/fixtures/branch_in_loop.rb')
      end

      it 'outputs error message' do
        expected_output = <<~EOS
          The target file does not exist. Check the file path: ./spec/fixtures/branch_in_loop.rb.
        EOS

        expect do
          CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        end.to output(expected_output).to_stdout
      end

      it 'returns 2' do
        expect(run_silently(['./spec/fixtures/branch_in_loop.rb'])).to eq 2
      end
    end

    context 'Another error is raised' do
      before do
        allow(CodeKeeper::Finder).to receive(:new).and_raise(StandardError.new('Error occurs!'))
      end

      it 'outputs error message' do
        expected_output = "Error occurs!\n"
        expect do
          CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        end.to output(expected_output).to_stdout
      end

      it 'returns 1' do
        expect(run_silently(['./spec/fixtures/branch_in_loop.rb'])).to eq 1
      end
    end
  end
end
