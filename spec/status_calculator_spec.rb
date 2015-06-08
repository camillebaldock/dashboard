require 'spec_helper'
require 'status_calculator'

describe StatusCalculator do

  let(:settings) { {} }
  let(:number) { Random.rand(100) }
  let(:result) { described_class.new(settings).run(number) }

  context "its settings are an attention, a danger and a warning value" do
    context "number is < to attention" do
      it "returns ok" do
        expect(result).to eq "ok"
      end
    end
    context "number is >= to attention and < danger" do
      it "returns attention" do
        expect(result).to eq "attention"
      end
    end
    context "number is == danger" do
      it "returns danger" do
        expect(result).to eq "danger"
      end
    end
    context "number is >= danger and < warning" do
      it "returns danger" do
        expect(result).to eq "danger"
      end
    end
    context "number is == to warning" do
      it "returns warning" do
        expect(result).to eq "warning"
      end
    end
    context "number is > to warning" do
      it "returns warning" do
        expect(result).to eq "warning"
      end
    end
  end

  context "its settings are only a danger value" do
    context "number is < to danger" do
      it "returns ok" do
        expect(result).to eq "ok"
      end
    end
    context "number is >= to danger" do
      it "returns danger" do
        expect(result).to eq "danger"
      end
    end
  end

  context "its settings are an attention and a warning value" do
    context "number is < to attention" do
      it "returns ok" do
        expect(result).to eq "ok"
      end
    end
    context "number is >= to attention and < to warning" do
      it "returns attention" do
        expect(result).to eq "attention"
      end
    end
    context "number is >= to warning" do
      it "returns warning" do
        expect(result).to eq "warning"
      end
    end
  end
end
