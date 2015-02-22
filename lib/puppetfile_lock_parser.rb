class PuppetfileLockParser
  def initialize(file_content)
    @releases = parse_file(file_content)
  end

  def releases
    @releases
  end

private

  def parse_file(content)
    lines = content.split("\n")
    results = {}
    lines.each_with_index do |line, line_index|
      if line.include?("GITHUBTARBALL")
        remote = lines[line_index+1]
        release = lines[line_index+3]
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
