# wtls

`wtls` lists Git worktrees by recent activity. Unlike sorting worktree
directories, it uses the newest modified project file in each worktree, so
editing an existing file immediately moves that worktree up the list.

## Quickstart

Install once, then run `wtls` from any Git repository:

```sh
# Install
brew tap calebcauthon/wtls https://github.com/calebcauthon/wtls
brew install wtls

# List this repository's worktrees, newest activity first
cd ~/Code/your-project
wtls

# Jump to the newest worktree matching a branch name or path
cd "$(wtls checkout)"
```

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

This repository is also a Homebrew tap. Because its GitHub repository is named
`wtls` rather than `homebrew-wtls`, pass the repository URL when tapping it for
the first time:

```sh
brew tap calebcauthon/wtls https://github.com/calebcauthon/wtls
brew install wtls
```

After that, Homebrew updates `wtls` with the usual commands:

```sh
brew update
brew upgrade wtls
```

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
