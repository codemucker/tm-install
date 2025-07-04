TM_INSTALL_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"

_cfg_load --this --key TM_INSTALL_STATE_DIR --default \$TM_STATE_DIR/tm-install/var --no-prompt

TM_INSTALL_PACKAGES_DIR="$TM_INSTALL_HOME/packages"

_cfg_load --this --key TM_INSTALL_GIT_REPO_DIR --default \$HOME/.local/tm-install/git-repo

TM_INSTALL_REGISTRIES="$TM_INSTALL_HOME/packages/custom $TM_INSTALL_HOME/packages/default"

TM_INSTALL_LIB_BIN="$TM_INSTALL_STATE_DIR/lib/bin"
export PATH="$PATH:$TM_INSTALL_LIB_BIN"