#!/usr/bin/env bash
# Claude Code status line — render real Starship prompt + Claude extras.
# Left: starship prompt (same as terminal). Right: model, ctx%, time.

input=$(cat)

cwd=$(echo "$input"      | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"    | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ---- Render starship from target dir ----
# --terminal-width large so starship doesn't truncate.
# Strip trailing newline (statusline is single line).
strip_wrappers() {
  # Remove zsh %{ %} and bash \[ \] non-printing markers
  sed -e 's/\\\[//g' -e 's/\\\]//g' -e 's/%{//g' -e 's/%}//g' | tr -d '\n'
}

if [[ -n "$cwd" && -d "$cwd" ]]; then
  starship_out=$(cd "$cwd" && STARSHIP_SHELL=bash starship prompt --terminal-width=500 2>/dev/null | strip_wrappers)
else
  starship_out=$(STARSHIP_SHELL=bash starship prompt --terminal-width=500 2>/dev/null | strip_wrappers)
fi

# ---- Right-side Claude extras ----
gray='\033[90m'
blue='\033[34m'
reset='\033[0m'

right_parts=()
[[ -n "$model" ]] && right_parts+=("${blue}${model}${reset}")
if [[ -n "$used_pct" ]]; then
  printf -v pct_int '%.0f' "$used_pct"
  right_parts+=("${gray}ctx:${pct_int}%${reset}")
fi
right_parts+=("${gray}$(date +%H:%M)${reset}")

right=""
for part in "${right_parts[@]}"; do
  right="${right:+$right  }${part}"
done

printf "%b  %b|  %b\n" "$starship_out" "$gray$reset" "$right"
