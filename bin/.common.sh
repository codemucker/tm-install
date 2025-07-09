TM_INSTALL_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"

_cfg_load --this --key TM_INSTALL_STATE_DIR --default \$TM_STATE_DIR/tm-install/var --no-prompt

TM_INSTALL_PACKAGES_DIR="$TM_INSTALL_HOME/packages"

_cfg_load --this --key TM_INSTALL_GIT_REPO_DIR --default \$HOME/.local/tm-install/git-repo

TM_INSTALL_REGISTRIES="$TM_INSTALL_HOME/packages/custom $TM_INSTALL_HOME/packages/default"

TM_INSTALL_LIB_BIN="$TM_INSTALL_STATE_DIR/lib/bin"
export PATH="$PATH:$TM_INSTALL_LIB_BIN"

#
# Check if installed, and if not, install it, else fail.
#
# Arguments
# $1 - program - the program to check
# $2 - package - (optional) the package to install. Defaults to 'pkg:$program'
#
_ensure_installed_or_fail(){
    if ! _ensure_installed "$1" "$2"; then
      _fail
    fi
}

#
# Check if installed, and if not, install it. Returns true if it's now installed and available
#
# Arguments
# $1 - program - the program to check
# $2 - package - (optional) the package to install. Defaults to 'pkg:$program'
#
_ensure_installed(){
    local program="${1}"
    local package="${2:-"pkg:${program}"}"

    if ! _is_installed "${program}"; then
      if _confirm "The program '$program' is not installed, install it? ($package)"; then
        # todo: search for packages
        tm-install '${package}'
      else
        _error "Program '${program}' is missing and not installing"
        return $_false
      fi
    fi
}

#
# Check if the given program installed, returning success or fail
#
# Arguments
# $1 - the program to check
#
_is_installed(){
    local program="${1}"
    if ! command -v "${program}"; then
      return $_false
    fi
    return $_true
}

#
# Read the gprovided install string or filem, and populate the provided array
#
# Arguments: 
# $1 - (required) the file or string to parse for instructions
# $2 - (required) the associative array to put the parse results in
#
_tm::install::read_install_details(){
  local file_or_parts="$1"
  local -n parts="$2"
  if [[ "${file_or_parts}" == *".conf" ]] && [[ -f "${file_or_parts}" ]]; then
    # the install string is a conf file
    _finest "reading install conf '${file_or_parts}'"
    _tm::io::conf::read_file parts "${file_or_parts}"
  else
    # parse the install string directly
    _finest "parsing csv string '${file_or_parts}'"
    _tm::io::csv::to_array "${file_or_parts}" parts
  fi

}