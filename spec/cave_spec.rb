require 'cave'

RSpec.describe Cave do
  context "Simple test file" do
    let(:testsdir) { "tests" }
    let(:infilename) { File.join(testsdir, "simple_cave.txt") }
    let(:outfilename) { File.join(testsdir, "simple_out.txt") }
    let(:output) { File.readlines(outfilename) }
    subject { File.open(infilename) {|f| Cave.new(file: f) } }

    it "should return the same output as supplied output file" do
      subject.simulate
      expect(subject.output).to eq output[0].chomp
    end
  end
end
