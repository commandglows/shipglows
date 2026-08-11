#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  capture_tmux_conversation.sh [shipglows|docs|N] [--tab N] [--title TITLE] [--destination PATH] [--session NAME] [--preset shipglows|docs] [--dry-run] [--yes]

Target:
  --tab N              Optional user-facing 1-based tmux tab/window ordinal.
                       The script resolves the actual tmux window index.
                       Omit to capture the current tmux pane.

Preset:
  --preset shipglows|docs  Output routing profile. `shipglows` routes to the ShipGlows-owned canonical conversation corpus.
                         Legacy alias `docs` routes to <project>/shipglows_data/workflow/conversations/. It never creates root docs/.
  shipglows|docs           Shortcut positional preset.

Optional:
  --title TITLE        Markdown title. Inferred when omitted.
  --destination PATH   Output file path or directory. Inferred when omitted.
  --session NAME       tmux session name. Defaults to current session or the only session.
  --dry-run            Print the inferred plan without writing.
  --yes                Skip interactive confirmation.
  --force              Allow overwriting an existing output file.
  -h, --help           Show this help.
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

SHIPGLOWS_PRESET="docs"

infer_shipglows_root() {
  local fallback_root="$1"
  local candidate="${SHIPGLOWS_ROOT:-${HOME}/.shipglows/runtime}"

  if [ -d "$candidate" ] && [ -d "$candidate/skills" ] && [ -d "$candidate/shipglows_data" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  if [ -d "$fallback_root" ] && [ -d "$fallback_root/skills" ] && [ -d "$fallback_root/shipglows_data" ]; then
    printf '%s\n' "$fallback_root"
    return 0
  fi

  candidate="${HOME}/.shipglows/runtime"
  if [ -d "$candidate" ] && [ -d "$candidate/skills" ] && [ -d "$candidate/shipglows_data" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  return 1
}

ensure_path_under_dir() {
  local path="$1"
  local allowed_dir="$2"
  local path_real allowed_real

  path_real=$(realpath -m "$path")
  allowed_real=$(realpath -m "$allowed_dir")
  case "$path_real" in
    "$allowed_real"/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_shipglows_preset_output() {
  local output="$1"
  local root="$2"
  local allowed_dir="$root/shipglows_data/workflow/conversations"

  if ! ensure_path_under_dir "$output" "$allowed_dir"; then
    fail "shipglows preset output must stay under $allowed_dir (got: $output). Use the legacy docs preset alias for canonical project-local conversation files."
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

trim() {
  sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

first_prompt_from_raw() {
  local raw_file="$1"
  awk '
    /^› / {
      line = $0
      sub(/^›[[:space:]]*/, "", line)
      print line
      exit
    }
  ' "$raw_file" | trim
}

last_prompt_from_raw() {
  local raw_file="$1"
  awk '
    /^› / {
      line = $0
      sub(/^›[[:space:]]*/, "", line)
      last = line
    }
    END {
      if (last != "") print last
    }
  ' "$raw_file" | trim
}

prompt_count_from_raw() {
  local raw_file="$1"
  awk '
    /^› / { count++ }
    END { print count + 0 }
  ' "$raw_file"
}

capture_quality_score() {
  local raw_file="$1"
  awk '
    BEGIN { prompts = 0; agent = 0; user = 0; nonempty = 0 }
    /^› / { prompts++ }
    /^• / { agent++ }
    /^│ / { agent++ }
    /^[[:space:]]*$/ { next }
    { nonempty++ }
    END {
      print (prompts * 20) + (agent * 3) + nonempty
    }
  ' "$raw_file"
}

capture_mode_label() {
  local use_alternate="$1"
  if [ "$use_alternate" = "1" ]; then
    printf '%s\n' "alternate-screen"
  else
    printf '%s\n' "scrollback"
  fi
}

shorten_words() {
  awk -v max="${1:-72}" '
    {
      out = ""
      for (i = 1; i <= NF; i++) {
        candidate = out == "" ? $i : out " " $i
        if (length(candidate) > max) break
        out = candidate
      }
      print out
    }
  '
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

expand_tilde() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${1#~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

absolute_path() {
  local path
  path=$(expand_tilde "$1")
  realpath -m "$path"
}

with_md_extension() {
  local path="$1"
  case "$path" in
    *.md|*.markdown) printf '%s\n' "$path" ;;
    *) printf '%s.md\n' "$path" ;;
  esac
}

unique_path() {
  local path="$1"
  local stem ext candidate index

  if [ "${FORCE:-0}" = "1" ] || [ ! -e "$path" ]; then
    printf '%s\n' "$path"
    return 0
  fi

  ext="${path##*.}"
  stem="${path%.*}"
  index=2
  while :; do
    candidate="${stem}-${index}.${ext}"
    if [ ! -e "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    index=$((index + 1))
  done
}

shell_quote() {
  printf '%q' "$1"
}

neovim_command() {
  local output="$1"
  local output_dir output_file
  output_dir=$(dirname "$output")
  output_file=$(basename "$output")
  printf 'cd %s && nvim %s\n' "$(shell_quote "$output_dir")" "$(shell_quote "$output_file")"
}

find_project_root_for_path() {
  local candidate="$1"
  local dir

  [ -e "$candidate" ] || return 1
  if [ -f "$candidate" ]; then
    dir=$(dirname "$candidate")
  else
    dir="$candidate"
  fi

  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -d "$dir/.git" ] || [ -f "$dir/package.json" ] || { [ -d "$dir/skills" ] && [ -f "$dir/README.md" ]; }; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done

  return 1
}

infer_project_root_from_raw() {
  local raw_file="$1"
  local cwd="$2"
  local candidate cleaned root

  while IFS= read -r candidate; do
    cleaned=$(printf '%s' "$candidate" | sed -E 's/[`"'"'"'<>),.;:]+$//')
    root=$(find_project_root_for_path "$cleaned" 2>/dev/null || true)
    if [ -n "$root" ]; then
      printf '%s\n' "$root"
      return 0
    fi
  done < <(grep -Eo '/[^[:space:]`"'"'"'<>),;]+' "$raw_file" | sort -u)

  if grep -Eqi '(^|[^a-z0-9-])(shipglows|sg-[a-z0-9-]+)([^a-z0-9-]|$)' "$raw_file"; then
    root=$(find_project_root_for_path "$HOME/.shipglows/runtime" 2>/dev/null || true)
    if [ -n "$root" ]; then
      printf '%s\n' "$root"
      return 0
    fi
  fi

  if root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
    printf '%s\n' "$root"
  else
    printf '%s\n' "$cwd"
  fi
}

infer_title_from_raw() {
  local raw_file="$1"
  local fallback="$2"
  local prompt skill text

  if grep -qi '001-sg-build' "$raw_file" && grep -Eqi 'architecture (de|des|of).{0,40}skills?|skills?.{0,40}architecture' "$raw_file"; then
    printf '%s\n' "Conversation 001-sg-build - architecture des skills"
    return 0
  fi

  if grep -Eqi 'doctrine.{0,40}langue|langue.{0,40}doctrine|language.{0,40}doctrine' "$raw_file"; then
    printf '%s\n' "Conversation ShipGlows - doctrine de langue"
    return 0
  fi

  prompt=$(
    awk '
      /^› [/$%]/ {
        line = $0
        sub(/^›[[:space:]]*/, "", line)
        print line
        exit
      }
    ' "$raw_file" | trim
  )

  if [ -z "$prompt" ]; then
    prompt=$(first_prompt_from_raw "$raw_file")
  fi

  if [ -n "$prompt" ]; then
    skill=$(printf '%s' "$prompt" | sed -nE 's#^[$/]([a-z0-9-]+).*#\1#p')
    text=$(printf '%s' "$prompt" | sed -E 's#^[$/][a-z0-9-]+[[:space:]]*##; s/[[:space:]]+/ /g' | trim | shorten_words 72 | trim)
    if [ -n "$skill" ] && [ -n "$text" ]; then
      printf 'Conversation %s - %s\n' "$skill" "$text"
      return 0
    fi
    if [ -n "$text" ]; then
      printf 'Conversation - %s\n' "$text"
      return 0
    fi
    if [ -n "$skill" ]; then
      printf 'Conversation %s\n' "$skill"
      return 0
    fi
  fi

  printf '%s\n' "$fallback"
}

resolve_session() {
  local requested="$1"
  local count

  if [ -n "$requested" ]; then
    tmux has-session -t "$requested" 2>/dev/null || fail "tmux session not found: $requested"
    printf '%s\n' "$requested"
    return 0
  fi

  if [ -n "${TMUX:-}" ]; then
    tmux display-message -p '#S'
    return 0
  fi

  count=$(tmux list-sessions -F '#S' 2>/dev/null | wc -l | tr -d ' ')
  case "$count" in
    0) fail "no tmux session is running" ;;
    1) tmux list-sessions -F '#S' ;;
    *) fail "multiple tmux sessions found; pass --session NAME" ;;
  esac
}

render_markdown() {
  local raw_file="$1"
  local output="$2"
  local title="$3"
  local session="$4"
  local source_label="$5"
  local window_index="$6"
  local pane_index="$7"
  local window_name="$8"
  local captured_at="$9"
  local capture_mode="${10}"
  local first_prompt="${11}"
  local last_prompt="${12}"
  local prompt_count="${13}"
  local max_tildes fence_len fence

  max_tildes=$(awk '
    {
      line = $0
      while (match(line, /~+/)) {
        if (RLENGTH > max) max = RLENGTH
        line = substr(line, RSTART + RLENGTH)
      }
    }
    END { print max + 0 }
  ' "$raw_file")
  fence_len=$((max_tildes + 1))
  if [ "$fence_len" -lt 3 ]; then
    fence_len=3
  fi
  printf -v fence '%*s' "$fence_len" ''
  fence=${fence// /~}

  {
    printf '# %s\n\n' "$title"
    printf '%s\n' "- Captured at: \`$captured_at\`"
    printf '%s\n' "- tmux session: \`$session\`"
    printf '%s\n' "- tmux source: \`$source_label\`"
    printf '%s\n' "- tmux window index: \`:$window_index\`"
    printf '%s\n' "- tmux pane index: \`.$pane_index\`"
    printf '%s\n' "- tmux window name: \`$window_name\`"
    printf '%s\n' "- capture mode: \`$capture_mode\`"
    printf '%s\n' "- prompt count: \`$prompt_count\`"
    if [ -n "$first_prompt" ]; then
      printf '%s\n' "- first prompt: \`$first_prompt\`"
    fi
    if [ -n "$last_prompt" ]; then
      printf '%s\n' "- last prompt: \`$last_prompt\`"
    fi
    printf '\n'
    printf '%s\n' "$fence"
    cat "$raw_file"
    printf '\n%s\n' "$fence"
  } > "$output"
}

TAB=""
TITLE=""
DESTINATION=""
SESSION=""
DRY_RUN=0
YES=0
FORCE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    shipglows)
      SHIPGLOWS_PRESET="shipglows"
      shift
      ;;
    docs)
      SHIPGLOWS_PRESET="docs"
      shift
      ;;
    --tab)
      [ "$#" -ge 2 ] || fail "--tab requires a value"
      TAB="$2"
      shift 2
      ;;
    --title)
      [ "$#" -ge 2 ] || fail "--title requires a value"
      TITLE="$2"
      shift 2
      ;;
    --destination|--dest|--output|-o)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      DESTINATION="$2"
      shift 2
      ;;
    --session)
      [ "$#" -ge 2 ] || fail "--session requires a value"
      SESSION="$2"
      shift 2
      ;;
    --preset)
      [ "$#" -ge 2 ] || fail "--preset requires a value"
      case "$2" in
        shipglows)
          SHIPGLOWS_PRESET="shipglows"
          ;;
        docs)
          SHIPGLOWS_PRESET="docs"
          ;;
        *)
          fail "unsupported preset: $2"
          ;;
      esac
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes|-y)
      YES=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ -z "$TAB" ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        TAB="$1"
        shift
      else
        fail "unknown argument: $1"
      fi
      ;;
  esac
done

need_cmd tmux
need_cmd awk
need_cmd sed
need_cmd realpath

if [ -n "$TAB" ]; then
  [[ "$TAB" =~ ^[0-9]+$ ]] || fail "--tab must be a positive integer"
  [ "$TAB" -ge 1 ] || fail "--tab must be >= 1"

  SESSION=$(resolve_session "$SESSION")
  WINDOW_INDEX=$(tmux list-windows -t "$SESSION" -F '#{window_index}' | sed -n "${TAB}p")
  [ -n "$WINDOW_INDEX" ] || fail "tmux tab $TAB not found in session $SESSION"
  TARGET="${SESSION}:${WINDOW_INDEX}"

  tmux display-message -p -t "$TARGET" '#{window_index}' >/dev/null 2>&1 \
    || fail "tmux window not found for tab $TAB (target $TARGET)"

  PANE_INDEX=$(tmux display-message -p -t "$TARGET" '#{pane_index}')
  WINDOW_NAME=$(tmux display-message -p -t "$TARGET" '#W')
  ALTERNATE_ON=$(tmux display-message -p -t "$TARGET" '#{alternate_on}')
  SOURCE_LABEL="tab ${TAB}"
else
  [ -z "$SESSION" ] || fail "--session without --tab is ambiguous; omit --session to capture the current pane or pass --tab N"
  tmux display-message -p '#S' >/dev/null 2>&1 \
    || fail "no current tmux pane found; pass --tab N from inside tmux or run from the pane to capture"
  SESSION=$(tmux display-message -p '#S')
  WINDOW_INDEX=$(tmux display-message -p '#{window_index}')
  PANE_INDEX=$(tmux display-message -p '#{pane_index}')
  WINDOW_NAME=$(tmux display-message -p '#W')
  ALTERNATE_ON=$(tmux display-message -p '#{alternate_on}')
  TARGET="${SESSION}:${WINDOW_INDEX}.${PANE_INDEX}"
  SOURCE_LABEL="current pane"
fi
CAPTURED_AT=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

TMP_RAW=$(mktemp)
TMP_ALT=$(mktemp)
trap 'rm -f "$TMP_RAW" "$TMP_ALT"' EXIT

tmux capture-pane -t "$TARGET" -p -J -S - > "$TMP_RAW"
CAPTURE_MODE=$(capture_mode_label 0)

if [ "${ALTERNATE_ON:-0}" = "1" ]; then
  tmux capture-pane -t "$TARGET" -p -J -a -S - > "$TMP_ALT"
  PRIMARY_SCORE=$(capture_quality_score "$TMP_RAW")
  ALT_SCORE=$(capture_quality_score "$TMP_ALT")
  if [ "$ALT_SCORE" -gt "$PRIMARY_SCORE" ]; then
    cp "$TMP_ALT" "$TMP_RAW"
    CAPTURE_MODE=$(capture_mode_label 1)
  fi
fi

PROMPT_COUNT=$(prompt_count_from_raw "$TMP_RAW")
FIRST_PROMPT=$(first_prompt_from_raw "$TMP_RAW")
LAST_PROMPT=$(last_prompt_from_raw "$TMP_RAW")

if [ -z "$TITLE" ]; then
  if [ -z "$TAB" ] && [ -n "$WINDOW_NAME" ]; then
    TITLE="Conversation tmux - panneau courant - ${WINDOW_NAME}"
  elif [ -z "$TAB" ]; then
    TITLE="Conversation tmux - panneau courant"
  elif [ -n "$WINDOW_NAME" ]; then
    TITLE="Conversation tmux - onglet ${TAB} - ${WINDOW_NAME}"
  else
    TITLE="Conversation tmux - onglet ${TAB}"
  fi
  TITLE=$(infer_title_from_raw "$TMP_RAW" "$TITLE")
fi

if [ -z "$DESTINATION" ]; then
  STAMP=$(date -u '+%Y%m%d-%H%M%S')
  SLUG=$(slugify "$TITLE")
  if [ -z "$SLUG" ]; then
    SLUG="conversation-onglet-${TAB}-${STAMP}"
  else
    SLUG="${SLUG}-${STAMP}"
  fi
  if [ "$SHIPGLOWS_PRESET" = "shipglows" ]; then
    SHIPGLOWS_ROOT_RESOLVED=$(infer_shipglows_root "${HOME}/.shipglows/runtime") \
      || fail "cannot resolve ShipGlows root; set SHIPGLOWS_ROOT to the ShipGlows repository"
    DESTINATION="${SHIPGLOWS_ROOT_RESOLVED}/shipglows_data/workflow/conversations/${SLUG}.md"
  else
    PROJECT_ROOT=$(infer_project_root_from_raw "$TMP_RAW" "$PWD")
    if [ -n "$PROJECT_ROOT" ] && [ "$PROJECT_ROOT" != "$PWD" ]; then
      DESTINATION="${PROJECT_ROOT}/shipglows_data/workflow/conversations/${SLUG}.md"
    elif [ -n "$PROJECT_ROOT" ] && [ -d "$PROJECT_ROOT/.git" ]; then
      DESTINATION="${PROJECT_ROOT}/shipglows_data/workflow/conversations/${SLUG}.md"
    else
      DESTINATION="./${SLUG}.md"
    fi
  fi
elif [ -d "$(expand_tilde "$DESTINATION")" ] || [[ "$DESTINATION" == */ ]]; then
  SLUG=$(slugify "$TITLE")
  [ -n "$SLUG" ] || SLUG="conversation-onglet-${TAB}"
  DESTINATION="${DESTINATION%/}/${SLUG}.md"
else
  DESTINATION=$(with_md_extension "$DESTINATION")
fi

OUTPUT=$(absolute_path "$DESTINATION")
OUTPUT=$(unique_path "$OUTPUT")
if [ "$SHIPGLOWS_PRESET" = "shipglows" ]; then
  SHIPGLOWS_ROOT_RESOLVED=$(infer_shipglows_root "${HOME}/.shipglows/runtime") \
    || fail "cannot resolve ShipGlows root; set SHIPGLOWS_ROOT to the ShipGlows repository"
  validate_shipglows_preset_output "$OUTPUT" "$SHIPGLOWS_ROOT_RESOLVED"
fi

print_plan() {
  printf 'Title: %s\n' "$TITLE"
  printf 'Destination: %s\n' "$OUTPUT"
  printf 'tmux target: %s (%s, window index :%s, pane index .%s)\n' "$TARGET" "$SOURCE_LABEL" "$WINDOW_INDEX" "$PANE_INDEX"
  printf 'tmux window name: %s\n' "$WINDOW_NAME"
  printf 'capture mode: %s\n' "$CAPTURE_MODE"
  printf 'prompt count: %s\n' "$PROMPT_COUNT"
  if [ -n "$FIRST_PROMPT" ]; then
    printf 'first prompt: %s\n' "$FIRST_PROMPT"
  fi
  if [ -n "$LAST_PROMPT" ]; then
    printf 'last prompt: %s\n' "$LAST_PROMPT"
  fi
  printf 'Neovim command: %s' "$(neovim_command "$OUTPUT")"
}

if [ "$DRY_RUN" = "1" ]; then
  print_plan
  exit 0
fi

if [ "$YES" != "1" ]; then
  print_plan
  if [ ! -t 0 ]; then
    fail "confirmation required; rerun with --yes after the user approves this destination"
  fi
  printf 'OK? Press Enter/y to capture, type a new destination, or type q/no to abort: '
  IFS= read -r ANSWER
  case "$ANSWER" in
    ""|y|Y|yes|YES|o|O|oui|OUI)
      ;;
    q|Q|n|N|no|NO|non|NON)
      printf 'Aborted.\n'
      exit 2
      ;;
    *)
      DESTINATION=$(with_md_extension "$ANSWER")
      OUTPUT=$(absolute_path "$DESTINATION")
      OUTPUT=$(unique_path "$OUTPUT")
      if [ "$SHIPGLOWS_PRESET" = "shipglows" ]; then
        SHIPGLOWS_ROOT_RESOLVED=$(infer_shipglows_root "${HOME}/.shipglows/runtime") \
          || fail "cannot resolve ShipGlows root; set SHIPGLOWS_ROOT to the ShipGlows repository"
        validate_shipglows_preset_output "$OUTPUT" "$SHIPGLOWS_ROOT_RESOLVED"
      fi
      printf 'New destination: %s\n' "$OUTPUT"
      ;;
  esac
fi

mkdir -p "$(dirname "$OUTPUT")"
render_markdown "$TMP_RAW" "$OUTPUT" "$TITLE" "$SESSION" "$SOURCE_LABEL" "$WINDOW_INDEX" "$PANE_INDEX" "$WINDOW_NAME" "$CAPTURED_AT" "$CAPTURE_MODE" "$FIRST_PROMPT" "$LAST_PROMPT" "$PROMPT_COUNT"

printf 'Captured tmux target %s to %s\n' "$TARGET" "$OUTPUT"
printf 'Open with Neovim: %s' "$(neovim_command "$OUTPUT")"
