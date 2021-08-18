# frozen_string_literal: true

RSpec.describe CodeKeeper::Cli do
  describe '.run' do
    context 'normal cases' do
      it 'outputs scores to stdout' do
        expected_output = <<~EOS
          Scores:

          Metric: cyclomatic_complexity
          Filename: ./spec/fixtures/branch_in_loop.rb
          Score: 2
          ---
        EOS

        expect do
          CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        end.to output(expected_output).to_stdout
      end

      it 'returns 0' do
        ret = CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        expect(ret).to eq 0
      end
    end

    context 'No argument is specified' do
      it 'returns 2' do
        expect(CodeKeeper::Cli.run([])).to eq 2
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
        ret = CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        expect(ret).to eq 2
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
        ret = CodeKeeper::Cli.run(['./spec/fixtures/branch_in_loop.rb'])
        expect(ret).to eq 1
      end
    end
  end
end
