Claude Code's `@` file autocomplete excludes gitignored files and can be pretty slow on large repos.

Solution: a bash script that replaces Claude Code's default file suggestion with `fd` + `fzf`.
it's a lot faster and customizable.

See [`file-suggestion.sh`](file-suggestion.sh) for the implementation, a short explanation under [how it works](#how-it-works).


## Setup

### 1. Add file suggestion script

Install prerequisites (macOS), clone repo, copy file, make executable:
```bash
brew install fd fzf jq
git clone https://github.com/eelcovdw/claude-code-extras.git
cp claude-code-extras/file-suggestion/file-suggestion.sh ~/.claude/file-suggestion.sh
chmod +x ~/.claude/file-suggestion.sh
```

### 2. Add to Claude code settings

Add this to `~/.claude/settings.json`, and restart claude code

```json
{
  "fileSuggestion": {
    "type": "command",
    "command": "$HOME/.claude/file-suggestion.sh"
  }
}
```

## Customization

Edit the arrays at the top of `file-suggestion.sh`:

- **INCLUDE** — gitignored paths you want in autocomplete. Use `"glob|directory"` for scoped searches or just `"glob"` to search from the project root.
- **EXCLUDE** — paths to hide even if they're not gitignored

## How it works

1. `fd` lists all non-ignored files (fast, respects `.gitignore`)
2. A second pass with `fd --no-ignore` picks up the explicitly included gitignored paths
3. `awk '!seen[$0]++'` deduplicates between different fd passes
   - Use awk instead of `sort -u` because sort buffers all input before outputting, awk streams line by line.
     On the Linux kernel repo (100k files), it cut down search time from 200ms to 50ms.
4. `fzf --filter` does fuzzy matching against the query
5. Results are capped at 15 entries

## Performance

```console
$ git clone git@github.com:microsoft/vscode.git && cd vscode
$ fd --type f --hidden --follow --exclude .git | wc -l
9262
$ echo '{"query":"server"}' | ~/.claude/file-suggestion.sh | head -5
src/server-cli.ts
src/server-main.ts
resources/server/favicon.ico
resources/server/code-512.png
resources/server/code-192.png
$ time (echo '{"query":"server"}' | ~/.claude/file-suggestion.sh > /dev/null) 2>&1
0,04s user 0,04s system 380% cpu 0,020 total

$ git clone git@github.com:torvalds/linux.git && cd linux
$ fd --type f --hidden --follow --exclude .git | wc -l
99782
$ echo '{"query":"server"}' | ~/.claude/file-suggestion.sh | head -5
fs/afs/server.c
fs/smb/server/vfs.h
fs/smb/server/vfs.c
fs/smb/server/ndr.h
fs/smb/server/ndr.c
$ time (echo '{"query":"server"}' | ~/.claude/file-suggestion.sh > /dev/null) 2>&1
0,26s user 0,11s system 645% cpu 0,056 total
```

~20ms on VS Code (~9k files), ~56ms on the Linux kernel (~100k files).

## References

- [Claude Code settings: `fileSuggestion`](https://code.claude.com/docs/en/settings)
- [fd](https://github.com/sharkdp/fd) — fast file finder in Rust, respects `.gitignore` by default
- [fzf](https://github.com/junegunn/fzf) — fuzzy finder
- [GitHub issue #8530](https://github.com/anthropics/claude-code/issues/8530) — improving `@` file search for large repos
- [@thayto_dev](https://x.com/thayto_dev/status/2009401734213554494) — original `rg` + `fzf` file suggestion script that inspired this
