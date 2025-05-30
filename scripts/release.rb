require "net/http"
require "json"
require "digest"

version = ARGV[0]
if version == nil
  abort "Usage: release.rb [x.y.z]"
else
  version = version.gsub(/[a-z-]*/i, "")
end

puts "Releasing infraspec on Homebrew: v#{version}"

url = "https://api.github.com/repos/robmorgan/infraspec/releases/tags/v#{version}"
response = Net::HTTP.get_response(URI(url))
unless response.is_a?(Net::HTTPSuccess)
  abort "Did not find release: infraspec-v#{version} [status: #{response.code}]"
end

release = JSON.parse(response.body)
puts "Found release: #{release["name"]}"

assets = {}
for asset in release["assets"]
  filename = asset["name"]
  if !filename.end_with?(".zip") || filename.include?("-profile")
    puts "Skipped asset: #{filename}"
    next
  end

  url = asset["browser_download_url"]
  begin
    response = Net::HTTP.get_response(URI(url))
    url = response["location"]
  end while response.is_a?(Net::HTTPRedirection)

  unless response.is_a?(Net::HTTPSuccess)
    abort "Did not find asset: #{filename} [status: #{response.code}]"
  end

  sha256 = Digest::SHA256.hexdigest(response.body)
  puts "Found asset: #{filename} [sha256: #{sha256}]"

  assets[filename] = sha256
end

formula = ""
File.open("Formula/infraspec.rb", "r") do |file|
  file.each_line do |line|
    query = line.strip

    new_line = if query.start_with?("version")
      line.gsub(/"[0-9\.]{1,}"/, "\"#{version}\"")
    elsif query.start_with?("sha256")
      asset = query[(query.index("#") + 2)..-1].strip
      sha256 = assets[asset]
      if sha256 == nil
        abort "Did not find sha256: #{asset}"
      end
      line.gsub(/"[A-Fa-f0-9]{1,}"/, "\"#{sha256}\"")
    else
      line
    end

    formula += new_line
  end
end

versioned_class = "class infraspecAT#{version.gsub(/\./, "")}"
versioned_formula = formula.gsub(/class infraspec/, versioned_class)
File.write("Formula/infraspec@#{version}.rb", versioned_formula)
puts "Saved Formula/infraspec@#{version}.rb"

File.write("Formula/infraspec.rb", formula)
puts "Saved Formula/infraspec.rb"

readme = File.read("README.md")
new_readme = readme.gsub(/infraspec@[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}/, "infraspec@#{version}")
File.write("README.md", new_readme)
puts "Saved README.md"

puts "Done"