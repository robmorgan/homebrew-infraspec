class Infraspec < Formula
  desc "Test your cloud infrastructure in plain English, no code required."
  homepage "https://infraspec.sh"
  url "https://github.com/robmorgan/infraspec/archive/v0.0.4.tar.gz"

  sha256 "4218acf668c060633184d4b7519be7bc49ee233ef5abd4378f2eb4cf223e1ff5"
  license "FCL-1.0-ALv2"
  version "0.0.4"
  head "https://github.com/robmorgan/infraspec.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

def install
    ldflags = %W[
      -s -w
      -X github.com/robmorgan/infraspec/cmd.Version=#{tap.version}
    ]

    system "go", "build", *std_go_args(ldflags:), "cmd"
  end

  test do
    system "#{bin}/infraspec", "--version"
  end
end
