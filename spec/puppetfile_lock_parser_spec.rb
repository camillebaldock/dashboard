require 'spec_helper'
require 'puppetfile_lock_parser'

describe PuppetfileLockParser do
  let(:file_path) { File.join(File.dirname(__FILE__), 'data', 'Puppetfilesample.lock') }

  it "returns the releases as mentioned in the Puppetfile" do
    parser = described_class.new(file_path)
    expect(parser.releases).to eq({
      "LudereSolutions/puppet-reflector" => "1.0.0",
      "Spantree/puppet-switchresx" => "0.9.1",
    })
  end
end
