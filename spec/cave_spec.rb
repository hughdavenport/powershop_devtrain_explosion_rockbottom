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
  context "Complex test file" do
    # We got the output file by testing our output manually, which passed
    let(:testsdir) { "tests" }
    let(:infilename) { File.join(testsdir, "complex_cave.txt") }
    let(:outfilename) { File.join(testsdir, "complex_out.txt") }
    let(:output) { File.readlines(outfilename) }
    subject { File.open(infilename) {|f| Cave.new(file: f) } }

    it "should return the same output as supplied output file" do
      subject.simulate
      expect(subject.output).to eq output[0].chomp
    end
  end

  describe "Movement" do
    context "Can only move left" do
      let(:teststring) {
        ['2','',
          "###",
          "~ #",
          "###",
        ].join("\n")
      }
      let(:expectedstring) {
        ['1','',
          "###",
          "~~#",
          "###",
          '',
        ].join("\n")
      }
      subject { Cave.new(file: StringIO.new(teststring)) }

      it "should fill the gap to the left" do
        subject.simulate
        expect(subject.to_s).to eq expectedstring
      end
    end
    context "Can only fall down" do
      let(:teststring) {
        ['2','',
          "###",
          "~~#",
          "# #",
          "###",
        ].join("\n")
      }
      let(:expectedstring) {
        ['1','',
          "###",
          "~~#",
          "#~#",
          "###",
          '',
        ].join("\n")
      }
      subject { Cave.new(file: StringIO.new(teststring)) }

      it "should fill the gap to the bottom" do
        subject.simulate
        expect(subject.to_s).to eq expectedstring
      end
    end
    context "Can go left or down" do
      let(:teststring) {
        ['2','',
          "####",
          "~~ #",
          "# ##",
          "####",
        ].join("\n")
      }
      let(:expectedstring) {
        ['1','',
          "####",
          "~~ #",
          "#~##",
          "####",
          '',
        ].join("\n")
      }
      subject { Cave.new(file: StringIO.new(teststring)) }

      it "should fill the gap to the bottom" do
        subject.simulate
        expect(subject.to_s).to eq expectedstring
      end
    end
    context "Can only flow up" do
      let(:teststring) {
        ['2','',
          "####",
          "~~ #",
          "#~~#",
          "####",
        ].join("\n")
      }
      let(:startstring) {
        ['2','',
          "####",
          "~~ #",
          "#~@#", # use debugging string for water loc
          "####",
          '',
        ].join("\n")
      }
      let(:flowstring) {
        ['2','',
          "####",
          "~@ #", # use debugging string for water loc
          "#~~#",
          "####",
          '',
        ].join("\n")
      }
      let(:expectedstring) {
        ['1','',
          "####",
          "~~@#",
          "#~~#",
          "####",
          '',
        ].join("\n")
      }
      subject { Cave.new(debug: true, file: StringIO.new(teststring)) }

      it "should have the watersource in bottom left" do
        expect(subject.to_s).to eq startstring
      end
      it "flow up should move the watersource up" do
        subject.flowUp
        expect(subject.to_s).to eq flowstring
      end
      it "should fill the last gap" do
        subject.simulate
        expect(subject.to_s).to eq expectedstring
      end
    end
    context "Overflowing" do
      let(:teststring) {
        ['2','',
          "###",
          "~~#",
          "###",
          '',
        ].join("\n")
      }
      subject { Cave.new(file: StringIO.new(teststring)) }

      it "should stop trying to fill up" do
        subject.simulate
        expect(subject.to_s).to eq teststring
      end
    end
  end
  describe "Optional features" do
# The following is out of original scope, but seemed cool
    context "Moving to the right" do
      let(:teststring) {
        ['2','',
          "###",
          "# ~",
          "###",
        ].join("\n")
      }
      let(:expectedstring) {
        ['1','',
          "###",
          "#~~",
          "###",
          ''
        ].join("\n")
      }
      subject { Cave.new(file: StringIO.new(teststring)) }

      it "should fill up to the right" do
        subject.simulate
        expect(subject.to_s).to eq expectedstring
      end
    end
    context "Underhang" do
      let(:teststring) {
        ['10','',
          "######",
          "~    #",
          "# ## #",
          "# #  #",
          "######",
        ].join("\n")
      }
      let(:expectedstring) {
        ['1','',
          "######",
          "~~~~~#",
          "#~##~#",
          "#~#~~#",
          "######",
          ''
        ].join("\n")
      }
      subject { Cave.new(file: StringIO.new(teststring)) }

      it "should fill up the underhang" do
        subject.simulate
        expect(subject.to_s).to eq expectedstring
      end
    end
    describe "Underhang shelf" do
      context "Almost filled" do
        let(:teststring) {
          ['9','',
            "#####",
            "~   #",
            "### #",
            "##  #",
            "### #",
            "##  #",
            "#####",
          ].join("\n")
        }
        let(:expectedstring) {
          ['1', '',
            "#####",
            "~~~~#",
            "###~#",
            "## ~#",
            "###~#",
            "##~~#",
            "#####",
            '',
          ].join("\n")
        }

        subject { Cave.new(file: StringIO.new(teststring)) }

        it "should fill up all but the overhang with only 9" do
          subject.simulate
          expect(subject.to_s).to eq expectedstring
        end
      end
      context "Filled" do
        let(:teststring) {
          ['10','',
            "#####",
            "~   #",
            "### #",
            "##  #",
            "### #",
            "##  #",
            "#####",
          ].join("\n")
        }
        let(:expectedstring) {
          ['1', '',
            "#####",
            "~~~~#",
            "###~#",
            "##~~#",
            "###~#",
            "##~~#",
            "#####",
            '',
          ].join("\n")
        }

        subject { Cave.new(file: StringIO.new(teststring)) }

        it "should fill up all including overhang shelf" do
          subject.simulate
          expect(subject.to_s).to eq expectedstring
        end
      end
    end
    describe "Spilling evenly" do
      context "Bottom row" do
        let(:teststring) {
          ['5','',
            "###~###",
            "#     #",
            "#     #",
            "#######",
          ].join("\n")
        }
        let(:expectedstring) {
          ['1','',
            "###~###",
            "#  ~  #",
            "# ~~~ #",
            "#######",
            '',
          ].join("\n")
        }

        subject { Cave.new(file: StringIO.new(teststring)) }

        it "should flow evenly" do
          subject.simulate
          expect(subject.to_s).to eq expectedstring
        end
      end
      context "Top row" do
        let(:teststring) {
          ['9','',
            "###~###",
            "#     #",
            "#     #",
            "#######",
          ].join("\n")
        }
        let(:expectedstring) {
          ['1','',
            "###~###",
            "# ~~~ #",
            "#~~~~~#",
            "#######",
            '',
          ].join("\n")
        }

        subject { Cave.new(file: StringIO.new(teststring)) }

        it "should flow evenly" do
          subject.simulate
          expect(subject.to_s).to eq expectedstring
        end
      end
    end
    describe "Multiple data sources" do
      context "Not overlapping" do
        let(:teststring) {
          ['3','',
            "###~##",
            "~ #  #",
            "# ####",
            "######",
          ].join("\n")
        }
        let(:expectedstring) {
          ['1','',
            "###~##",
            "~~#~~#",
            "#~####",
            "######",
            '',
          ].join("\n")
        }
        subject { Cave.new(file: StringIO.new(teststring)) }

        it "should fill up from both sources" do
          subject.simulate
          expect(subject.to_s).to eq expectedstring
        end
      end
    end
  end
end
