class PuppetfileLockParser
  def initialize(file_path)
    file = File.open(file_path, 'r')
    @releases = parse_file(file)
    file.close
  end

  def releases
    @releases
  end

private

  def parse_file(file)
    results = {}
    loop do
      break if not line = file.gets
      if line.include?("GITHUBTARBALL")
        remote = file.gets
        file.gets
        release = file.gets
        opening_index = release.index('(')+1
        closing_index = release.index(')')-1
        version_number = release[opening_index..closing_index]
        repo = remote.match(/\sremote:\s(\S*)/)[1]
        results[repo] = version_number;
      end
    end
    results
  end
end
