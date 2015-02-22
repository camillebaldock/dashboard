require 'spec_helper'
require 'puppetfile_lock_parser'

describe PuppetfileLockParser do
  let(:file_path) { File.join(File.dirname(__FILE__), 'data', 'Puppetfilesample.lock') }

  it "returns the releases as mentioned in the Puppetfile" do
    content = File.open(file_path).read
    parser = described_class.new(content)
    expect(parser.releases).to eq({
      "LudereSolutions/puppet-reflector" => "1.0.0",
      "Spantree/puppet-switchresx" => "0.9.1",
    })
  end
end
