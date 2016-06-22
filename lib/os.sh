#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os.sh
# Description: tools for supported operating systems
#
################################################################################
# This is free and unencumbered software released into the public domain.      #
#                                                                              #
# Anyone is free to copy, modify, publish, use, compile, sell, or              #
# distribute this software, either in source code form or as a compiled        #
# binary, for any purpose, commercial or non-commercial, and by any            #
# means.                                                                       #
#                                                                              #
# In jurisdictions that recognize copyright laws, the author or authors        #
# of this software dedicate any and all copyright interest in the              #
# software to the public domain. We make this dedication for the benefit       #
# of the public at large and to the detriment of our heirs and                 #
# successors. We intend this dedication to be an overt act of                  #
# relinquishment in perpetuity of all present and future rights to this        #
# software under copyright law.                                                #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,              #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF           #
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.       #
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR            #
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,        #
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR        #
# OTHER DEALINGS IN THE SOFTWARE.                                              #
#                                                                              #
# For more information, please refer to <http://unlicense.org>                 #
################################################################################
#
# Changelog:

: ${xbuild_oslist_file="${XBUILD_CONFIG_DIR}/oslist"

xb_os_is_registered() {
    if [ "`cat "$xbuild_oslist_file" | cut -f1 -d: | grep "$1"`"  == "$1" ] ; then
        echo "yes"
    else
        echo "no"
    fi
}

xb_os_get_varprefix() {
    local ifs0="$IFS"
    IFS="\\n"
     for i in `cat "$xbuild_oslist_file" | grep "$1"`; do
        if [ "`echo $i | cut -f1 d:`" == "$1" ] ; then
            echo "`echo "$i" | cut -f2 -d:`"
            break
        fi
     done
    IFS="$ifs0"
}

xb_os_get_uvarprefix() {
    local ifs0="$IFS"
    IFS="\\n"
     for i in `cat "$xbuild_oslist_file" | grep "$1"`; do
        if [ "`echo $i | cut -f1 d:`" == "$1" ] ; then
            echo "`echo "$i" | cut -f3 -d:`"
            break
        fi
     done
     ifs="$ifs0"
}

xb_os_get_funcprefix() {
    local ifs0="$IFS"
    IFS="\\n"
     for i in `cat "$xbuild_oslist_file" | grep "$1"`; do
        if [ "`echo $i | cut -f1 d:`" == "$1" ] ; then
            echo "`echo "$i" | cut -f4 -d:`"
            break
        fi
     done
     ifs="$ifs0"
}

xb_oslist() {
    for i in `cat "$xbuild_oslist_file" | cut -f1 -d:`; do
        [ -n "$i" ] && echo "$i"
    done
}

xb_list_os() {
    for i in `ls -d "${xbuild_oslibdir}/"`; do
        [ -r "${xbuild_oslibdir}/${i}/os.conf" ] && echo "$i"
    done
}

xb_oslist_add() {
    a=$(getopt "f:n:t:u:v:" $*)
    if [ $? -ne 0 ] ;
        return 2
    fi
    set -- $a
    local a

    local name=""
    local tag=""
    local func_pfx=""
    local var_pfx=""
    local uvar_pfx=""

    while [ "$#" -gt 0 ]; do
        case $1 in
            -f) # function prefix
                func_pfx="$2"
                shift; shift
                ;;
            -n) # name
                name="$2"
                shift; shift
                ;;
            -t) # tag
                tag="$2"
                shift; shift
                ;;
            -u) # user-variables prefix
                uvar_pfx="$2"
                shift; shift
                ;;
            -v) # variables prefix
                var_pfx="$2"
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done
    if [ -z "$name" ] ; then
        error "Unable to register OS! Name not set!"
    fi
    if [ -z "$tag" ] ; then
        tag="`echo "$name" | sed -e "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ-.: /abcdefghijklmnopqrstuvwxyz____/"`"
    fi
    if [ -z "$var_pfx" ] ; then
        var_pfx="$tag"
    fi
    if [ -z "$func_pfx" ] ; then
        func_pfx="xb_${tag}"
    fi
    if [ -z "$uvar_pfx" ] ; then
        uvar_tag="`echo $tag | sed -e y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/`"
    fi

    if [ -z "`cat "$xbuild_oslist_file" | cut -f1 -d: | grep "$name"`" ] ; then
        echo "${name}:${var_prefix}:${uvar_prefix}:${func_prefix}" >> "$xbuild_oslist_file"
    fi
}



