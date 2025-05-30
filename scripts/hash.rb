require "open-uri"
require "digest"

version = ARGV[0]
if version == nil
  abort "Usage: hash.rb [x.y.z]"
else
  version = version.gsub(/[a-z-]*/i, "")
end

puts "Calculating hash for infraspec: v#{version}"
url = "https://github.com/robmorgan/infraspec/archive/v#{version}.tar.gz"

begin
  content = URI.open(url).read
  puts "Found release: v#{version}"
  sha256 = Digest::SHA256.hexdigest(content)
  puts "Found asset: v#{version}.tar.gz [sha256: #{sha256}]"
rescue OpenURI::HTTPError => e
  abort "Did not find release: v#{version} [status: #{e.message}]"
end
