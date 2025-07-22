class Infraspec < Formula
  desc "Test your cloud infrastructure in plain English, no code required."
  homepage "https://infraspec.sh"
  url "https://github.com/robmorgan/infraspec/archive/refs/tags/v0.0.7.tar.gz"
  sha256 "2d18d072698649918a7120084316d45b27fa0b039bb90be003f892b0a2667e54"
  license "Apache-2.0"
  version "0.0.7"
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
