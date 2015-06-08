require 'spec_helper'
require 'status_calculator'

describe StatusCalculator do

  let(:settings) {
    {
      "attention" => attention,
      "danger" => danger,
      "warning" => warning
    }
  }
  let(:attention) { 5 }
  let(:danger) { 20 }
  let(:warning) { 50 }
  let(:number) { Random.rand(100) }
  let(:result) { described_class.new(settings).run(number) }

  context "its settings are an attention, a danger and a warning value" do
    context "number is < to attention" do
      let(:number) { rand(0..attention-1) }
      it "returns ok" do
        expect(result).to eq "ok"
      end
    end
    context "number is >= to attention and < danger" do
      let(:number) { rand(attention..danger-1) }
      it "returns attention" do
        expect(result).to eq "attention"
      end
    end
    context "number is >= danger and < warning" do
      let(:number) { rand(danger..warning-1) }
      it "returns danger" do
        expect(result).to eq "danger"
      end
    end
    context "number is >= to warning" do
      let(:number) { rand(warning..warning+1000) }
      it "returns warning" do
        expect(result).to eq "warning"
      end
    end
  end

  context "its settings are only a danger value" do
    let(:settings) {
      {
        "danger" => danger
      }
    }
    context "number is < to danger" do
      let(:number) { rand(0..danger-1) }
      it "returns ok" do
        expect(result).to eq "ok"
      end
    end
    context "number is >= to danger" do
      let(:number) { rand(danger..danger+1000) }
      it "returns danger" do
        expect(result).to eq "danger"
      end
    end
  end
end
