
TM_INSTALL_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
TM_INSTALL_PACKAGES_DIR="${TM_INSTALL_PACKAGES_DIR:-"$TM_INSTALL_HOME/packages"}"
TM_INSTALL_GIT_REPO_DIR="${TM_INSTALL_GIT_REPO_DIR:-"$(tm-cfg-get --this --key TM_INSTALL_GIT_REPO_DIR --default \$HOME/.local/tm-install/git-repo)"}"
TM_INSTALL_REGISTRIES="${TM_INSTALL_REGISTRIES:-"$TM_INSTALL_HOME/packages/custom $TM_INSTALL_HOME/packages/default"}"
TM_INSTALL_VAR_DIR="${TM_INSTALL_VAR_DIR:-"$(tm-cfg-get --this --key TM_INSTALL_VAR_DIR --default \$TM_VAR_DIR/tm-install/var --no-prompt)"}"



