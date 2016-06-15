#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/misc.sh
# Description: Description
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

################################################################################
# Print functions
################################################################################
: ${xbuild_verbose_level:=3}

debug()
{
    local eargs=""

    if ([ "$1" == "-e" ] || [ "$1" == "-n" ]) ; then
        eargs="$1"
        shift
    fi
    if [ $xbuild_verbose_level -ge 3 ] ; then
        builtin echo ${eargs} "[DEBUG] $*"
    fi
}

message2() {
    if [ $xbuild_verbose_level -ge 3] ; then
        local eargs=""
        if ([ "$1" == "-e" ] || [ "$1" == "-n" ]) ; then
            eargs="$1"
            shift
        fi

        builtin echo ${eargs} "[DEBUG] > $*"
    fi
}

################################################################################
# Boolean Comaprison
################################################################################



xb_error() {
    builtin echo "[ERROR] $*" >&2
}

xb_boolean() {
    if [ -z "$1" ] ; then
        local x="no"
    else
        local x="`echo $1 | sed -e s/1/yes/ -e s/y/yes/i -e s/"true"/yes/i -e s/yes/yes/i -e s/on/yes/i -e s/[0]/no/ -e s/n/no/i -e s/"false"/no/i -e s/no/no/i -e s/off/no/i`"
    fi

    if ([ "$x" == "yes" ] || [ "$x" == "no" ]) ; then
        builtin echo $x
    else
        return 1
    fi
}

xb_is_true() {
    local x=$(xb_boolean $1)
    if [ $? -ne 0 ]; then
        return 1
    fi
    builtin echo "$x"
}

xb_is_false() {
    local x=$(xb_boolean $1)
    if [ $? -ne 0 ]; then
        return 1
    fi
    if [ "$x" == "no" ] ; then
        builtin echo "yes"
    else
        builtin echo "no"
    fi
}

################################################################################
# xbuild_os_list functions
################################################################################

# name install current

