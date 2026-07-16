#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WTLS="$ROOT/bin/wtls"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/wtls-test.XXXXXX")"
TMP="$(cd "$TMP" && pwd -P)"
trap 'rm -rf "$TMP"' EXIT

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

pass() {
    printf 'ok - %s\n' "$1"
}

assert_before() {
    local output="$1"
    local first="$2"
    local second="$3"
    local first_line second_line

    first_line="$(printf '%s\n' "$output" | awk -v value="$first" 'index($0, value) { print NR; exit }')"
    second_line="$(printf '%s\n' "$output" | awk -v value="$second" 'index($0, value) { print NR; exit }')"

    [[ -n "$first_line" && -n "$second_line" && "$first_line" -lt "$second_line" ]] ||
        fail "expected $first before $second"
}

[[ "$($WTLS --version)" == "wtls 0.1.0" ]] || fail '--version returns the release version'
pass '--version returns the release version'

$WTLS --help | grep -q '^Usage: wtls \[pattern\]' || fail '--help prints usage'
pass '--help prints usage'

repo="$TMP/repo"
feature="$TMP/feature"
mkdir -p "$repo"
git -C "$repo" init -q -b main
git -C "$repo" config user.name 'wtls test'
git -C "$repo" config user.email 'wtls@example.com'
printf 'test\n' > "$repo/project.txt"
git -C "$repo" add project.txt
git -C "$repo" commit -qm 'initial'
git -C "$repo" worktree add -qb feature "$feature"

touch -t 202001010000 "$repo/project.txt"
touch -t 202401010000 "$feature/project.txt"
output="$(cd "$repo" && NO_COLOR=1 "$WTLS")"
assert_before "$output" "$feature" "$repo"
pass 'newest project file puts its worktree first'

touch -t 202501010000 "$repo/project.txt"
output="$(cd "$repo" && NO_COLOR=1 "$WTLS")"
assert_before "$output" "$repo" "$feature"
pass 'editing an existing file updates worktree order'

if command -v fzf >/dev/null 2>&1; then
    result="$(cd "$repo" && "$WTLS" feature 2>/dev/null)"
    [[ "$result" == "$feature" ]] || fail 'search prints only the matched path'
    pass 'search prints only the matched path'
fi

if (cd "$TMP" && "$WTLS" >/dev/null 2>&1); then
    fail 'running outside a Git repository fails'
fi
pass 'running outside a Git repository fails'
