#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/install.sh
# Description: Installation functions
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

# Add a target for installation
# $1        Target
# $2        Target name. Will be displayed in installer and config log.
#           If no message is set or Message is empty it is displayed as
#           "Installing $TARGET_NAME ...".
# [$3 ...]  Extra args for targets.
install_add_target() {
    if [ $# -eq 0 ] ; then
        error "xbuild_install_target() requires atleast 1 argument!"
        exit 2
    fi
    if [ -z "$1" ] ; then
        error "Installation target not set!"
        exit 2
    fi

    builtin echo -n "xbuild_install_target \"$1\"" >> "$xbuild_install_script"

    if ([ $# -eq 1 ] || [ -z "$2" ])
        builtin echo -n "\"$1\"" >> "$xbuild_install_script"
    else
        builtin echo -n "\"$2\"" >> "$xbuild_install_script"
    fi
    shift; shift

    while [ $# -gt 0 ] ; do
        builtin echo -n "\"$1\"" >> "$xbuild_install_script"
        shift
    done
    echo "" >> "$xbuild_install_script"
}

xbuild_install_cnt=0
xbuild_install_n_targets=0

xbuild_install_print_target() {
    i=0; local i

    while [ $i -lt 60 ] ; do
        echo -n "#"
        i=$(( $i + 1 ))
    done
    echo ""
    msg=$1; local msg
    i=$(( 2 + ${#msg} ))
    echo -n "# $1"
    while [ $i -lt 59 ] ; do
        echo -n " "
        i=$(( i + 1 ))
    done
    echo "#"

    i=0
    while [ $i -lt 60 ] ; do
        echo -n "#"
        i=$(( $i + 1 ))
    done
    echo ""
}

# WARNING: Don't call this function directly!
xbuild_install_target() {
    xbuild_install_cnt=$(( $xbuild_install_cnt + 1 ))

    target="$1"; local target
    message="$2"; local message
    shift; shift

    if [ "$xbuild_dialog_install" == "yes" ] ; then
        if [ $xbuild_install_cnt -ge $xbuild_install_n_tagets ] ; then
            perc=100
        else
            perc=$(( ($xbuild_install_cnt * 100) / xbuild_install_n_targets ))
        fi
        cat << __EOF__
XXX
$perc
$1
XXX
__EOF__
        shift
        xbuild_install_print_target "$message" >> "$xbuild_install_log"
        $target $@ 2>&1 >> "$xbuild_install_log"
    else
        xbuild_install_print_message "$message" | tee -a "$xbuild_install_log"
        $target $@ | tee -a "$xbuild_install_log"
    fi
}

xbuil_install_count_n_targets() {
}

xbuild_install_base() {
    if [ ! -d "$xbuild_install_dir" ] ; then
        echo "[DIR] $xbuild_install_dir"
        mkdir -p "$xbuild_install_dir"
    fi
    for i in config xbuild; do
        echo "[DIR] ${xbuild_install_dir}/$i"
        mkdir -p "${xbuild_install_dir}/$i"

        f="XBUILD_NO_PROJECT"
        echo "[FILE] ${xbuild_install_dir}/${f}"
        touch "${xbuild_install_dir}/${f}"
    done

    basedir="${xbuild_install_dir}/xbuild"; local basedir
    for i in scripts skel skel/config skel/mroot skel/mnt skel/work skel/img skel/pkg; do
        echo "[DIR] ${basedir}/${i}"
        mkdir -p "${basedir}/${i}"
    done
}

