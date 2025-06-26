_include @tm/lib.log.sh
_include @tm/lib.script.sh
_include @tm/lib.file.ini.sh
_include @tm/lib.file.csv.sh

_include .common.sh

export TM_INSTALL_PACKAGES_DIR="${TM_INSTALL_PACKAGES_DIR:-"$TM_INSTALL_HOME/packages"}"
export TM_INSTALL_GIT_REPO_DIR="${TM_INSTALL_GIT_REPO_DIR:-"$(tm-cfg-get --this --key TM_INSTALL_GIT_REPO_DIR --default "\$HOME/.local/tm-install/git-repo")"}"
export TM_INSTALL_REGISTRIES="${TM_INSTALL_REGISTRIES:-"$TM_INSTALL_HOME/packages"}"



