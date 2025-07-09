
_include @tm/lib.file.ini.sh

#
# Reads the package conf files and populates the specified associative array for the given package name.
# Usage: _tm::install::tpkg::read_conf <package_name> <output_array_name>
#
# Arguments:
# $1 - (required) the qualified package name
# $2 - required) the associative array to populate
#      Should result in an array with: 
#           qname           - qualified package name, including the namespace, vendor, package_name, version. User friendly format
#           qpath           - qualified package path (file name safe), including the namespace, vendor, package_name, ve.rsion 
#           vendor          - the package vendor
#           package_name    - the package vendor
#           version         - version
#           installer         - installer
#
_tm::install::tpkg::read_conf(){
    local qualified_name="$1"
    local -n result_ref="$2"
    
    local -A pkg
    _tm::install::tpkg::parse_package_name "$qualified_name" pkg
    local namespace="${pkg[namespace]:-}"
    local vendor="${pkg[vendor]:-default}"
    local package_name="${pkg[name]}"
    local version="${pkg[version]:-latest}"
    local qname="${pkg[qname]}"
    local qpath="${pkg[qpath]}"
        
    local try_pkg_conf_files=()
    
    for registry in $TM_INSTALL_REGISTRIES; do
        try_pkg_conf_files+=( 
            "$registry/$vendor/$package_name/$package_name@$version.conf"
            "$registry/$vendor/$package_name/$package_name.conf"
            "$registry/$vendor/$package_name/package@$version.conf"
            "$registry/$vendor/$package_name/package.conf"
            "$registry/$vendor/$package_name@$version.conf"
            "$registry/$vendor/$package_name.conf"
            "$registry/$vendor/package.conf"
            "$registry/package.conf"
        )
    done

    local section
    if [[  -z "${vendor}" ]]; then
        section="${package_name}"
    else
        section="${vendor}/${package_name}"
    fi

    for conf_file in "${try_pkg_conf_files[@]}"; do
        _trace "trying '$conf_file'"
        if [[ -f "$conf_file" ]]; then # found a package file 
            # Read package details from the file
            _trace "found conf file '${conf_file}'"
            
            _tm::file::ini::read_section result_ref "$conf_file" "${section}" 'multiline'

            if [[  "${#result_ref[@]}" -gt 0 ]]; then # found a matching section
                _debug "Package '$package_name' found in '$conf_file'."

                # set some common values
                result_ref[qname]="${qname}"
                result_ref[qpath]="${qpath}"
                result_ref[namespace]="${namespace}"
                result_ref[vendor]="${vendor}"
                result_ref[package_name]="${package_name}"
                result_ref[version]="${version}"
                result_ref[install_dir]="${TM_PACKAGES_DIR}/${qpath}"

                if [[ -z "${result_ref[installer]}" ]]; then
                    _fail "Invalid package config. Expected 'installer' but none was given. Instead got $(_tm::util::array::print result_ref) for package '${qname}'"
                fi

                return 0 
            else
                continue;
            fi
        fi
    done
    local msg="Could not find install package '$qualified_name' from any package files. Looked in"
    for conf_file in "${try_pkg_conf_files[@]}"; do
        msg+="\n $conf_file "
    done
    msg+="."
    _fail "$msg"
}

#
# Parse a qualified package name
#  namespace:vendor/package_name@version
#
_tm::install::tpkg::parse_package_name(){
    _trace "qualified_name '$1'"
    
    local qualified_name="$1"
    local -n result_ref="$2"

    local namespace package_name version vendor
    namespace=''
    package_name=''
    version=''
    vendor=''

    local remainder=''
    IFS=":" read -r namespace remainder <<< "$qualified_name"
    if [[ -z "$remainder" ]]; then
        remainder="$namespace"
        namespace=''        
    fi
    IFS="/" read -r vendor remainder <<< "$remainder"
    if [[ -z "$remainder" ]]; then
        remainder="$vendor"
        vendor=''        
    fi
    if [[ "${remainder}" =~ *"@"* ]]; then
        IFS="@" read -r package_name version <<< "$remainder"
    elif [[ "${remainder}" =~ *"#"* ]]; then
        IFS="#" read -r package_name version <<< "$remainder"
    else
        package_name="${remainder}"
        version=''
    fi

    local qname
    if [[ -z "${namespace}" ]]; then
        qname="${vendor}/${package_name}"
    else
        qname="${namespace}:${vendor}/${package_name}"
    fi
    if [[ -n "${version}" ]]; then
       qname+="@${version}" 
    fi
    local qpath="${vendor:-${__TM_NO_VENDOR}}/${package_name}"
    if [[ -n "${namespace}" ]]; then
      qpath+="__${namespace}"
    fi

    _is_debug && _debug "namespace='$namespace', vendor='$vendor', name='$package_name', version='$version', qname='$qname', qpath='$qpath'" || true

    result_ref=( [namespace]="$namespace" [vendor]="$vendor" [name]="$package_name" [version]="$version" [qname]="$qname" [qpath]="$qpath" )
    return 0
}

