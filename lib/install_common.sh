#!/usr/bin/env bash
# Shared helpers for module install scripts.

: "${REPO_ROOT:?REPO_ROOT must be set by the root installer}"
: "${MODULE_NAME:?MODULE_NAME must be set by the root installer}"

MODULE_DIR="$REPO_ROOT/$MODULE_NAME"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.cache/unix_configs/backups}"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-$MODULE_NAME"

module_log() {
  printf '\033[1;34m[%s]\033[0m %s\n' "$MODULE_NAME" "$*"
}

backup_if_needed() {
  local target="$1"

  if [[ -L "$target" || -f "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    local backup="$BACKUP_DIR/$(basename "$target")"
    mv "$target" "$backup"
    module_log "Backed up $target -> $backup"
  fi
}

install_config_file() {
  local source="$1"
  local target="$2"
  local mode="${3:-644}"

  if [[ ! -e "$source" ]]; then
    echo "[$MODULE_NAME] error: source does not exist: $source" >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"
  backup_if_needed "$target"
  install -m "$mode" "$source" "$target"
  module_log "Installed $target from $source (mode $mode)"
}

install_git_plugin() {
  local name="$1"
  local repo="$2"
  local commit="$3"
  local dir="$4"

  if [[ -d "$dir/.git" ]]; then
    module_log "Keeping existing $name checkout: $dir"
    return 0
  fi

  if [[ -e "$dir" ]]; then
    echo "[$MODULE_NAME] warning: $dir exists but is not a Git checkout; skipping $name" >&2
    return 0
  fi

  module_log "Installing $name ($commit)"
  mkdir -p "$(dirname "$dir")"
  git clone "$repo" "$dir"
  git -C "$dir" checkout "$commit"
}
