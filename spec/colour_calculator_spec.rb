require 'spec_helper'
require 'colour_calculator'

describe ColourCalculator do

  let(:config_repository) { double(:config_repository, :settings => settings) }
  let(:settings) {
    {
      "goal" => {
        "yellow" => yellow,
        "orange" => orange,
        "red" => red
      },
      "colour" => "cyan"
    }
  }
  let(:colour_settings) {
    {
      "colour" => "cyan"
    }
  }
  let(:yellow) { 5 }
  let(:orange) { 20 }
  let(:red) { 50 }
  let(:number) { Random.rand(100) }
  let(:result) { described_class.new(config_repository).get_colour(number) }

  context "no goal" do
    let(:settings) { { "colour" => "cyan" } }
    it "returns the colour indicated in the settings" do
      expect(result).to eq "cyan"
    end
  end

  context "has a decrease goal" do
    context "its settings are an yellow, an orange and a red value" do
      context "number is < to yellow" do
        let(:number) { rand(0..yellow-1) }
        it "returns green" do
          expect(result).to eq "#2EFE2E"
        end
      end
      context "number is >= to yellow and < orange" do
        let(:number) { rand(yellow..orange-1) }
        it "returns yellow" do
          expect(result).to eq "yellow"
        end
      end
      context "number is >= orange and < red" do
        let(:number) { rand(orange..red-1) }
        it "returns orange" do
          expect(result).to eq "orange"
        end
      end
      context "number is >= to warning" do
        let(:number) { rand(red..red+1000) }
        it "returns red" do
          expect(result).to eq "red"
        end
      end
    end

    context "its settings are only a danger value" do
      let(:settings) {
        {
          "goal" => {
            "orange" => orange
          }
        }
      }
      context "number is < to danger" do
        let(:number) { rand(0..orange-1) }
        it "returns green" do
          expect(result).to eq "#2EFE2E"
        end
      end
      context "number is >= to danger" do
        let(:number) { rand(orange..orange+1000) }
        it "returns orange" do
          expect(result).to eq "orange"
        end
      end
    end
  end

  context "has an increase goal" do
    let(:red) { 0 }
    let(:settings) {
        {
          "goal" => {
            "red" => red
          },
          "increase" => "true"
        }
      }
    context "its settings are a red value" do
      context "number is > to red" do
        let(:number) { rand(red..red+1000) }
        it "returns green" do
          expect(result).to eq "#2EFE2E"
        end
      end
      context "number is <= to red" do
        let(:number) { 0 }
        it "returns red" do
          expect(result).to eq "red"
        end
      end
    end
  end
end
