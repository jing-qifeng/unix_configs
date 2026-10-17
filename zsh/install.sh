#!/usr/bin/env bash
# Install the Zsh, fzf-tab, and Powerlevel10k configuration.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MODULE_NAME="zsh"
# shellcheck source=../lib/install_common.sh
source "$REPO_ROOT/lib/install_common.sh"

LOCAL_CONFIG_DIR="$HOME/.config/unix_configs"
LOCAL_CONFIG_FILE="$LOCAL_CONFIG_DIR/local.zsh"

ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
ZSH_THEME_DIR="$HOME/.local/share/zsh/themes"

FZF_TAB_REPO="https://github.com/Aloxaf/fzf-tab.git"
FZF_TAB_COMMIT="24105b1"
P10K_REPO="https://github.com/romkatv/powerlevel10k.git"
P10K_COMMIT="604f19a"

install_local_config_template() {
  mkdir -p "$LOCAL_CONFIG_DIR"
  chmod 700 "$LOCAL_CONFIG_DIR"

  if [[ ! -e "$LOCAL_CONFIG_FILE" ]]; then
    install -m 600 "$REPO_ROOT/local/zsh-local.example" "$LOCAL_CONFIG_FILE"
    module_log "Created private local config: $LOCAL_CONFIG_FILE"
  else
    module_log "Keeping existing private local config: $LOCAL_CONFIG_FILE"
  fi
}

install_plugins() {
  if [[ "${SKIP_PLUGIN_INSTALL:-0}" == "1" ]]; then
    module_log "Skipping Git plugin installation because SKIP_PLUGIN_INSTALL=1"
    return 0
  fi

  install_git_plugin \
    "fzf-tab" \
    "$FZF_TAB_REPO" \
    "$FZF_TAB_COMMIT" \
    "$ZSH_PLUGIN_DIR/fzf-tab"

  install_git_plugin \
    "Powerlevel10k" \
    "$P10K_REPO" \
    "$P10K_COMMIT" \
    "$ZSH_THEME_DIR/powerlevel10k"
}

main() {
  module_log "Installing Zsh configuration"

  install_config_file "$MODULE_DIR/zshrc" "$HOME/.zshrc" 644
  install_config_file "$MODULE_DIR/zshenv" "$HOME/.zshenv" 644
  install_config_file "$MODULE_DIR/p10k.zsh" "$HOME/.p10k.zsh" 600
  install_local_config_template
  install_plugins

  module_log "Restart Zsh with: exec zsh"
}

main "$@"
