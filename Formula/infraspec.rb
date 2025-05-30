class Infraspec < Formula
  desc "Test your cloud infrastructure in plain English, no code required."
  homepage "https://infraspec.sh"
  url "https://github.com/robmorgan/infraspec/archive/refs/tags/v0.0.4.tar.gz"
  sha256 "4218acf668c060633184d4b7519be7bc49ee233ef5abd4378f2eb4cf223e1ff5"
  license "FCL-1.0-ALv2"
  version "0.0.4"
  head "https://github.com/robmorgan/infraspec.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  def install
    infraspec_version = if build.stable?
      version.to_s
    else
      Utils.safe_popen_read("git", "describe", "--tags", "--dirty").chomp
    end

    with_env(
      "INFRASPEC_VERSION"   => infraspec_version,
      "GO_LDFLAGS"   => "-s -w",
      "GO_BUILDTAGS" => "updateable",
    ) do
      system "go", "run", "./script/build.go"
    end
    bin.install "bin/infraspec"
  end

  test do
    assert_match "infraspec version #{version}", shell_output("#{bin}/infraspec --version")
  end
end
