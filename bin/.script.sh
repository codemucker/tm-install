_include_once @tm/lib.log.sh @tm/lib.script.sh @tm/lib.file.ini.sh @tm/lib.io.conf.sh .common.sh

export TM_INSTALL_PACKAGES_DIR="${TM_INSTALL_PACKAGES_DIR:-"$TM_INSTALL_HOME/packages"}"
export TM_INSTALL_GIT_REPO_DIR="${TM_INSTALL_GIT_REPO_DIR:-"$(tm-cfg-get --this --key TM_INSTALL_GIT_REPO_DIR --default "\$HOME/.local/tm-install/git-repo")"}"
export TM_INSTALL_REGISTRIES="${TM_INSTALL_REGISTRIES:-"$TM_INSTALL_HOME/packages"}"



