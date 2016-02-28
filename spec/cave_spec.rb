require 'cave'

RSpec.describe Cave do
  context "Simple test file" do
    let(:testsdir) { "tests" }
    let(:infilename) { File.join(testsdir, "simple_cave.txt") }
    let(:outfilename) { File.join(testsdir, "simple_out.txt") }
    let(:input) { File.open(infilename) }
    after(:all) { input.close }
    let(:output) { File.readlines(outfilename) }
    subject { Cave.new(file: input) }

    it "should return the same output as supplied output file" do
      subject.simulate
      expect(subject.output).to eq output
    end
  end
end
