#!/usr/bin/env bash
# Install enabled user-level configuration modules.
#
# The module list is kept in install.modules. Each enabled module directory
# must provide its own executable install.sh.

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${MANIFEST:-$REPO_DIR/install.modules}"

log() {
  printf '\033[1;36m[root]\033[0m %s\n' "$*"
}

usage() {
  cat <<'EOF'
Usage: ./install.sh [MODULE...]

Install modules listed in install.modules, or only the specified modules when
MODULE arguments are provided.

Environment variables:
  MANIFEST=<path>       Use an alternate module manifest.
  SKIP_PLUGIN_INSTALL=1 Passed through to module installers that support it.

Examples:
  ./install.sh
  ./install.sh zsh
  MANIFEST=/path/to/install.modules ./install.sh
EOF
}

enabled_modules_from_manifest() {
  if [[ ! -f "$MANIFEST" ]]; then
    echo "error: manifest not found: $MANIFEST" >&2
    exit 1
  fi

  awk '
    {
      sub(/^[[:space:]]+/, "")
      sub(/[[:space:]]+$/, "")
      if ($0 == "" || $0 ~ /^#/) next
      print $0
    }
  ' "$MANIFEST"
}

validate_module_name() {
  local module="$1"

  if [[ ! "$module" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "error: unsafe module name in manifest: $module" >&2
    exit 1
  fi
}

run_module() {
  local module="$1"
  local module_dir="$REPO_DIR/$module"
  local installer="$module_dir/install.sh"

  validate_module_name "$module"

  if [[ ! -d "$module_dir" ]]; then
    echo "error: module directory not found: $module_dir" >&2
    exit 1
  fi

  if [[ ! -f "$installer" ]]; then
    echo "error: module installer not found: $installer" >&2
    exit 1
  fi

  if [[ ! -x "$installer" ]]; then
    echo "error: module installer is not executable: $installer" >&2
    exit 1
  fi

  log "Installing module: $module"
  (
    cd "$module_dir"
    REPO_ROOT="$REPO_DIR" MODULE_NAME="$module" ./install.sh
  )
  log "Finished module: $module"
}

main() {
  local -a modules=()

  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  if [[ $# -gt 0 ]]; then
    modules=("$@")
  else
    mapfile -t modules < <(enabled_modules_from_manifest)
  fi

  if [[ ${#modules[@]} -eq 0 ]]; then
    log "No modules enabled in $MANIFEST"
    exit 0
  fi

  log "Repository: $REPO_DIR"
  log "Manifest: $MANIFEST"

  local module
  for module in "${modules[@]}"; do
    run_module "$module"
  done

  log "All enabled modules completed"
}

main "$@"
