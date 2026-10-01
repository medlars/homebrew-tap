class Verdictui < Formula
  desc "SwiftUI verification engine giving semantic verdicts, not screenshots"
  homepage "https://github.com/medlars/verdictui-releases"
  # The source repo is private; this is the signed + notarized universal
  # binary published to the public assets-only releases repo.
  url "https://github.com/medlars/verdictui-releases/releases/download/v1.1.4/verdictui-1.1.4-macos-universal.zip"
  sha256 "bd497b340cb32a5087dbc82c84f5dba1ef36a0f0b20503154eee815cf22df386"
  license "MIT"

  # `macos: :ventura` already implies macOS, so a bare `depends_on :macos`
  # beside it is redundant AND deprecated — Homebrew warns on every load.
  # Ventura matches the binary's LC_BUILD_VERSION minos 13.0.
  depends_on macos: :ventura

  def install
    bin.install "verdictui"
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
