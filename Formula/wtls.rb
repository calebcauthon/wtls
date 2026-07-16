class Wtls < Formula
  desc "List Git worktrees by their most recently modified project file"
  homepage "https://github.com/calebcauthon/wtls"
  url "https://github.com/calebcauthon/wtls/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "aa89dfb001d690cc76f72c9db18df6a3361df1379fa163f5e62ade8d269ead4f"
  license "MIT"
  head "https://github.com/calebcauthon/wtls.git", branch: "main"

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
