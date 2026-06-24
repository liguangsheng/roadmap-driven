#!/usr/bin/env bash
# uninstall.sh - Remove the roadmap-driven skill from agent skills directories.
#
# By default it removes the skill from every default location where it may be
# installed (Codex, Claude Code, opencode). Use --agent to limit the scope or
# --target to remove a specific directory. The script only deletes a directory
# that looks like this skill (its SKILL.md declares name: roadmap-driven) or a
# symlink created by a --link install, unless --force is given.
#
# Supported agents and default locations:
#   codex     ~/.codex/skills/roadmap-driven            (override: CODEX_SKILLS_DIR)
#   claude    ~/.claude/skills/roadmap-driven           (override: CLAUDE_SKILLS_DIR)
#   opencode  ~/.config/opencode/skills/roadmap-driven  (override: OPENCODE_SKILLS_DIR)
#
# Usage:
#   ./uninstall.sh [options]
#
# Options:
#   --agent NAME   Remove for codex, claude, opencode, or all. May be repeated.
#                  Default: all supported agents.
#   --target DIR   Remove this exact directory instead of the per-agent defaults.
#   --dry-run      Show what would be removed without deleting anything.
#   --force        Remove even if the directory does not look like this skill.
#   -h, --help     Show this help and exit.

set -euo pipefail

readonly SKILL_NAME="roadmap-driven"
readonly SUPPORTED_AGENTS="codex claude opencode"

# --- output helpers ----------------------------------------------------------

if [ -t 1 ]; then
  C_BOLD=$'\033[1m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_RESET=$'\033[0m'
else
  C_BOLD=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_RESET=''
fi

log()  { printf '%s\n' "$*"; }
info() { printf '%s==>%s %s\n' "$C_BOLD" "$C_RESET" "$*" >&2; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()  { err "$*"; exit 1; }

print_help() {
  sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# --- arg parsing -------------------------------------------------------------

need_arg() { [ "$2" -ge 2 ] || die "$1 requires a value"; }

parse_args() {
  FORCE=no
  DRY_RUN=no
  TARGET=""
  AGENTS_SELECTED=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --agent)
        need_arg "$1" "$#"
        case "$2" in
          codex|claude|opencode|all) AGENTS_SELECTED="$AGENTS_SELECTED $2";;
          *) die "unknown agent: $2 (expected codex, claude, opencode, or all)";;
        esac
        shift 2;;
      --target)  need_arg "$1" "$#"; TARGET="$2"; shift 2;;
      --dry-run) DRY_RUN=yes; shift;;
      --force)   FORCE=yes; shift;;
      -h|--help) print_help; exit 0;;
      *)         die "unknown option: $1 (try --help)";;
    esac
  done
}

# --- agent resolution (mirrors install.sh) -----------------------------------

normalize_agents() {
  local raw="$1" out=""
  case " $raw " in *" all "*) raw="$SUPPORTED_AGENTS";; esac
  local a
  for a in $SUPPORTED_AGENTS; do
    case " $raw " in *" $a "*) out="$out $a";; esac
  done
  printf '%s' "${out# }"
}

agent_default_dir() {
  case "$1" in
    codex)    printf '%s' "${CODEX_SKILLS_DIR:-$HOME/.codex/skills}/$SKILL_NAME";;
    claude)   printf '%s' "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/$SKILL_NAME";;
    opencode) printf '%s' "${OPENCODE_SKILLS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills}/$SKILL_NAME";;
    *)        die "unknown agent: $1";;
  esac
}

# --- removal -----------------------------------------------------------------

is_our_skill() {
  # True if the path holds this skill, or is a (possibly dangling) symlink that
  # a --link install would have created at the skill path.
  local dir="$1"
  if [ -f "$dir/SKILL.md" ] \
     && grep -Eq "^name:[[:space:]]*${SKILL_NAME}[[:space:]]*$" "$dir/SKILL.md"; then
    return 0
  fi
  [ -L "$dir" ]
}

remove_one() {
  local agent="$1" dir="$2"

  if [ ! -e "$dir" ] && [ ! -L "$dir" ]; then
    info "not installed: $dir ($agent)"
    return 0
  fi

  if ! is_our_skill "$dir" && [ "$FORCE" != yes ]; then
    warn "skipping $dir ($agent): does not look like the $SKILL_NAME skill (pass --force to remove anyway)"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ "$DRY_RUN" = yes ]; then
    log "  [dry-run] would remove $dir ($agent)"
  else
    # No trailing slash and -- so a symlink target is never followed/deleted.
    rm -rf -- "$dir"
    log "  removed $dir ($agent)"
  fi
  REMOVED=$((REMOVED + 1))
}

# --- main --------------------------------------------------------------------

main() {
  parse_args "$@"
  : "${HOME:?HOME is not set; cannot determine default locations. Set a *_SKILLS_DIR override or pass --target.}"

  REMOVED=0
  SKIPPED=0

  if [ -n "$TARGET" ]; then
    remove_one custom "$TARGET"
  else
    local agents
    agents="$(normalize_agents "$AGENTS_SELECTED")"
    [ -n "$agents" ] || agents="$SUPPORTED_AGENTS"
    local a
    for a in $agents; do
      remove_one "$a" "$(agent_default_dir "$a")"
    done
  fi

  if [ "$REMOVED" -eq 0 ] && [ "$SKIPPED" -eq 0 ]; then
    log "${C_GREEN}nothing to do${C_RESET}: $SKILL_NAME is not installed in any checked location."
  elif [ "$DRY_RUN" = yes ]; then
    log "${C_GREEN}dry-run${C_RESET}: $REMOVED location(s) would be removed; $SKIPPED skipped."
  else
    log "${C_GREEN}uninstalled${C_RESET} $SKILL_NAME from $REMOVED location(s); $SKIPPED skipped."
  fi
}

main "$@"
