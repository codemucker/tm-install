
_include @tm/lib.file.ini.sh

#
# Reads the package init files and populates the specified associative array for the given package name.
# Usage: __tm_install_pkg_read_config <package_name> <output_array_name>
#
__tm_tpack_read_config(){
    local qualified_name="$1"
    local -n result_ref="$2"
    
    local -A pkg
    __tm_tpack_parse_package_name "$qualified_name" pkg
    local namespace="${pkg['namespace']:-}"
    local vendor="${pkg['vendor']:-no-vendor}"
    local package_name="${pkg['name']}"
    local version="${pkg['version']:-latest}"

    local try_pkg_ini_files=()
    
    for registry in $TM_INSTALL_REGISTRIES; do
        try_pkg_ini_files+=( 
            "$registry/$vendor/$package_name/$package_name@$version.ini" 
            "$registry/$vendor/$package_name/$package_name.ini" 
            "$registry/$vendor/$package_name/package@$version.ini" 
            "$registry/$vendor/$package_name/package.ini" 
            "$registry/$vendor/$package_name@$version.ini" 
            "$registry/$vendor/$package_name.ini"
            "$registry/$vendor/package.ini"
        )
    done

    for ini_file in "${try_pkg_ini_files[@]}"; do
        _trace "trying '$ini_file'"
        if [[ -f "$ini_file" ]]; then
            # found a package file 
            _trace "found '$ini_file'"
            # Check if the package section exists in the INI file
            if ! __tm_file_ini_has_section "$ini_file" "$package_name"; then
                _debug "Package '$package_name' not found in '$ini_file'."
                continue # next file
            fi

            _debug "Package '$package_name' found in '$ini_file'."
            # Read package details from the INI file
            __tm_file_ini_read_section "$ini_file" "$package_name" result_ref
            return 0 

            break
        fi
    done
    local msg="Could not find install package '$qualified_name' from any package files. Looked in"
    for ini_file in "${try_pkg_ini_files[@]}"; do
        msg+="\n $ini_file "
    done
    msg+="."
    _fail "$msg"
}

#
# Parse a qualified package name
#  namespace:vendor/package_name@version
#
__tm_tpack_parse_package_name(){
    _trace "__tm_tpack_parse_package_name: qualified_name '$1'"
    
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
    IFS="@" read -r package_name version <<< "$remainder"

    _trace "namespace='$namespace'"
    _trace "vendor='$vendor'"
    _trace "name='$package_name'"
    _trace "version='$version'"
    
    result_ref=( ['namespace']="$namespace" ['vendor']="$vendor" ['name']="$package_name" ['version']="$version" )
    return 0
}
