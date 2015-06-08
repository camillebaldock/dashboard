require 'spec_helper'
require 'status_calculator'

describe StatusCalculator do
  it "throws an exception if its argument is not an integer"
  it "throws an exception if it doesn't have an attention, danger or warning value"

  context "it is given an attention, a danger and a warning value" do
    it "returns ok if number is < to attention"
    it "returns attention if number is >= to attention and < danger"
    it "returns danger if number is == danger"
    it "returns danger if number is >= danger and < warning"
    it "returns warning if number is == to warning"
    it "returns warning if number is > to warning"
  end

  context "it is given only a danger value" do
    it "returns ok if number is < to danger"
    it "returns danger if number is >= to danger"
  end

  context "it is given an attention and a warning value" do
    it "returns ok if number is < to attention"
    it "returns attention if number is >= to attention and < to warning"
    it "returns warning if number is >= to warning"
  end
end
