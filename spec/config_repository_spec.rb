require 'config_repository'

describe ConfigRepository do
  let(:key) { "testkey" }
  let(:data_directory) { "spec/data/config/with"}
  let(:result) { described_class.new(key, data_directory) }
  let(:settings_result) { result.settings }
  let(:frequency_result) { result.frequency }
  let(:data_directory_without_key) { "spec/data/config/without"}

  context "the directory does not contain data for the key" do
    let(:result) { described_class.new(key, data_directory_without_key) }
    context "on initialisation" do
      it "throws a KeyError error" do
        expect { result }.to raise_error KeyError
      end
    end
  end

  context "the directory contains data for the key" do
    context "no settings" do
      let(:key) { "nosettingskey" }
      it "settings throws a KeyError error" do
        expect { settings_result }.to raise_error KeyError
      end
    end
    context "with settings" do
      it "settings returns the settings" do
        expect(settings_result).to eq({"goal"=>{"red"=>42}})
      end
    end
    context "no frequency" do
      let(:key) { "nofrequencykey" }
      it "frequency throws a KeyError error" do
        expect { frequency_result }.to raise_error KeyError
      end
    end
    context "with frequency" do
      it "frequency returns the frequency" do
        expect(frequency_result).to eq "1h"
      end
    end
  end

end
