require 'spec_helper'

describe Markov do
  before :each do
    @dummy_textfile = File.open('src/test.txt', 'r', :encoding => "UTF-8")
  end

  describe "#new" do
    it "should set :max_chain_length if given" do
      markov = Markov.new @dummy_textfile, :max_chain_length => 1

      expect( markov.max_chain_length ).to eq 1
    end

    it "should raise ArgumentError for invalid given :max_chain_length (zero)" do
      expect{ Markov.new @dummy_textfile, :max_chain_length => 0 }.to raise_error( ArgumentError, "invalid chain length" )
    end

    it "should raise ArgumentError for invalid given :max_chain_length (negative)" do
      expect{ Markov.new @dummy_textfile, :max_chain_length => -1 }.to raise_error( ArgumentError, "invalid chain length" )
    end
  end
end
