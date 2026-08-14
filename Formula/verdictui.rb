class Verdictui < Formula
  desc "SwiftUI verification engine giving semantic verdicts, not screenshots"
  homepage "https://github.com/medlars/verdictui"
  url "https://github.com/medlars/verdictui/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "7845d41ec906bb1616e7d3f1977efd60e95e9965c0be16343a10ccc9845abe58"
  license "MIT"
  head "https://github.com/medlars/verdictui.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  # `macos: :ventura` already implies macOS, so a bare `depends_on :macos`
  # beside it is redundant AND deprecated — Homebrew warns on every load.
  depends_on macos: :ventura

  def install
    system "swift", "build",
           "--disable-sandbox",
           "-c", "release",
           "--product", "verdictui"
    bin.install ".build/release/verdictui"
  end

  test do
    # `list` names the demo catalog the package ships, so a successful run
    # proves the binary starts AND resolved its scenarios — a version string
    # would prove only that it linked.
    output = shell_output("#{bin}/verdictui list")
    assert_match "demo-clean-settings", output

    # Exit code 1 is a real FAILING verdict, not an error: the three-valued
    # scheme reserves 2 for "no verdict could be produced". Asserting the
    # distinction here is what stops a broken install reading as a clean pass.
    fail_output = shell_output("#{bin}/verdictui verify demo-undersized-tap-target", 1)
    assert_match "tap-target", fail_output

    pass_output = shell_output("#{bin}/verdictui verify demo-clean-settings")
    assert_match "PASS", pass_output
  end
end
