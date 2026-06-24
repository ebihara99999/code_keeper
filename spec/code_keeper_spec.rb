# frozen_string_literal: true

RSpec.describe CodeKeeper do
  it "has a version number" do
    expect(CodeKeeper::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'set the default value to metrics' do
      expect(CodeKeeper.configure { |config| config }).to be_a CodeKeeper::Config
    end
  end
end
