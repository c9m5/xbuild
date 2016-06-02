#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/misc.sh
# Description: misc functions
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

# checks $1
# echos "yes" if true "no" if false
is_true() {
    if [ -z "$1" ] ; then
        x="no"
    else
        x="`echo $1 | sed -e s/1/yes/ -e s/"true"/yes/i -e s/yes/yes/i -e s/on/yes/i \
            -e s/"false"/no/i -e s/no/no/i -e s/off/no/i -e s/[0]/no/`"
    fi
    local x
    if ([ "$x" == "yes" ] || [ "$x" == "no" ]) ; then
        echo $x
        return 0
    fi
    return 1
}

error() {
    printerr="builtin echo"; local printerr
    case $1 in
        -e)
            printerr="$printerr -e"
            shift
            ;;
        -n)
            printerr="$printerr -n"
            shift
            ;;
    esac

    $printerr "$*" >&2
}

dialog_max_width() {
    echo "`dialog --print-maxsize | cut -f 3 -w -`"
}

dialog_max_height() {
    echo "`dialog --print-maxsize | cut -f 2 -w - | cut -f 1 -d , -`"
}

# Get the $OS_NAME from XBUILD_OS_LIST
# $1 = $OS_TAG
os_get_name_from_tag() {
    n=1; local n
    x=""; local x
    while [ $n -gt 0 ] ; do
        x="`echo "$XBUILD_OS_LIST" | cut -f $n -d ';' -`"
        if [ -z "$x" ] ; then
            return 1
        fi
        if [ "`echo "$x" | cut -f 1 -d ':' -`" == "$1" ] ; then
            echo "`echo "$x" | cut -f 2 -d ':'`"
            n=0
        else
            n=$(( n + 1 ))
        fi

    done
}

# Get the $OS_LIBDIR from XBUILD_OS_LIST
# $1 = $OS_TAG
os_get_libdir_from_tag() {
    n=1; local n
    x=""; local x
    while [ $n -gt 0 ] ; do
        x="`echo "$XBUILD_OS_LIST" | cut -f $n -d ';' -`"
        if [ -z "$x" ] ; then
            return 1
        fi
        if [ "`echo "$x" | cut -f 1 -d ':' -`" == "$1" ] ; then
            echo "`echo "$x" | cut -f 3 -d ':'`"
            n=0
        else
            n=$(( n + 1 ))
        fi
    done
}

# Get $OS_TAG from XBUILD_OS_LIST.
# $1 = $OS_NAME
os_get_tag_from_name() {
    n=1; local n
    x=""; local x
    while [ $n -gt 0 ] ; do
        x="`echo "$XBUILD_OS_LIST" | cut -f $n -d ';' -`"
        if [ -z "$x" ] ; then
            return 1
        fi
        if [ "`echo "$x" | cut -f 2 -d ':' -`" == "$1" ] ; then
            echo "`echo "$x" | cut -f 1 -d ':'`"
            n=0
        else
            n=$(( n + 1 ))
        fi
    done
}

# Get $OS_LIBDIRDIR from XBUILD_OS_LIST
# $1 = $OS_NAME
os_get_libdir_from_name() {
    n=1; local n
    x=""; local x
    while [ $n -gt 0 ] ; do
        x="`echo "$XBUILD_OS_LIST" | cut -f $n -d ';' -`"
        if [ -z "$x" ] ; then
            return 1
        fi
        if [ "`echo "$x" | cut -f 2 -d ':' -`" == "$1" ] ; then
            echo "`echo "$x" | cut -f 3 -d ':'`"
            n=0
        else
            n=$(( n + 1 ))
        fi
    done
}

