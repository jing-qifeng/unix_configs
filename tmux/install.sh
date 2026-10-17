#!/usr/bin/env bash
# Install the tmux configuration.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MODULE_NAME="tmux"
# shellcheck source=../lib/install_common.sh
source "$REPO_ROOT/lib/install_common.sh"

main() {
  module_log "Installing tmux configuration"
  install_config_file "$MODULE_DIR/tmux.conf" "$HOME/.tmux.conf" 644
}

main "$@"
