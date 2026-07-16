# wtls

`wtls` lists Git worktrees by recent activity. Unlike sorting worktree
directories, it uses the newest modified project file in each worktree, so
editing an existing file immediately moves that worktree up the list.

```text
today
feature/checkout-redesign  /Users/caleb/Code/checkout-redesign
main                       /Users/caleb/Code/app

yesterday
fix/receipt-email          /Users/caleb/Code/receipt-email
```

Tracked files and untracked, non-ignored files count as project activity. Git
metadata, ignored dependencies, and generated output do not affect ordering.

## Install with Homebrew

This repository includes a local Homebrew formula pinned to the `v0.1.0` tag:

```sh
brew install --formula /Users/caleb/Code/wtls/Formula/wtls.rb
```

After the repository is published, the formula URL can be changed to the GitHub
release tarball and installed from a tap.

## Use

List all worktrees for the current repository:

```sh
wtls
```

Find a worktree by branch or path and print only its path to stdout:

```sh
cd "$(wtls marketing)"
```

Search requires [`fzf`](https://github.com/junegunn/fzf), which Homebrew installs
as a dependency.

```text
Usage: wtls [pattern]

Options:
  -h, --help     Show help
  -v, --version  Show the version
```

## Develop

```sh
make test
```

The command supports macOS and Linux and requires Bash, Git, awk, and standard
Unix tools.
