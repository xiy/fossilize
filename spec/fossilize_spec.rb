require "spec_helper"
require "fossilize"

describe Fossilize do
  describe "#create" do
    it "should return a valid delta string from two String arguements" do
      Fossilize.create("Test", "Test String").should == "B\nB:Test String3U9pwb;"
    end

    it "should return a valid delta string from two File arguments" do
      f1 = File.open('Gemfile')
      f2 = File.open('Rakefile')
      Fossilize.create(f1, f2).should ==
        "l\nl:#!/usr/bin/env rake\nrequire \"bundler/gem_tasks\"\nhrAtN;"
    end

    it "should return a valid delta when the arguments contain a file path" do
      puts Fossilize.create('README.md', 'ext/fossil_delta/extconf.rb')
    end

    it "should return a valid delta when the arguments are mixed" do
      puts Fossilize.create('/Users/xiy/.zshrc', 'Is this in the README?')
    end
  end

  describe "#input_is_sane?" do
    it "should raise an ArgumentError if the input is an invalid type" do
      expect { Fossilize.check_input(1) }.to raise_error ArgumentError
    end

    it "should raise an ArgumentError if the input is nil" do
      expect { Fossilize.check_input(nil) }.to raise_error ArgumentError
    end
  end
end
