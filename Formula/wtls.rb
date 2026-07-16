class Wtls < Formula
  desc "List Git worktrees by their most recently modified project file"
  homepage "https://github.com/calebcauthon/wtls"
  url "file:///Users/caleb/Code/wtls",
      using:    :git,
      tag:      "v0.1.0",
      revision: "61f6958dc75b2f6ff87076834d3ad5d91c24aa84"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/wtls"
  end

  test do
    assert_match "wtls 0.1.0", shell_output("#{bin}/wtls --version")

    system "git", "init", "-q", "-b", "main", testpath/"repo"
    assert_match "main", shell_output("git -C #{testpath}/repo branch --show-current")
  end
end
