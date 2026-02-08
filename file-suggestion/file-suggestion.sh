#!/bin/bash
#
# Claude Code file suggestion command.
# Combines fd (fast find) + fzf (fuzzy filter) with support for
# including specific gitignored paths.
#
# Config: edit the arrays below — no extra files read at runtime.

# Gitignored paths to INCLUDE in search results
# Format: "glob|directory" or just "glob" (searches from root)
INCLUDE=(
  '*.md|.claude'
  'CLAUDE.md'
)

# Extra paths to EXCLUDE even if not gitignored (fd glob patterns)
EXCLUDE=(
  '.git'
)

# ---

# read all of stdin first, piping directly to jq loses input
input=$(cat)
query=$(echo "$input" | jq -r '.query')

exclude_args=()
for pat in "${EXCLUDE[@]}"; do
  exclude_args+=(--exclude "$pat")
done

{
  # Main file list (respects .gitignore + EXCLUDE)
  fd --type f --hidden --follow "${exclude_args[@]}" 2>/dev/null

  # Add INCLUDE paths
  for entry in "${INCLUDE[@]}"; do
    IFS='|' read -r pat dir <<< "$entry"
    if [[ -n "$dir" ]]; then
      fd --type f --no-ignore --hidden --follow --glob "$pat" "$dir" 2>/dev/null
    else
      fd --type f --no-ignore --hidden --follow --glob "$pat" 2>/dev/null
    fi
  done
} | awk '!seen[$0]++' | fzf --filter="$query" | head -15
