#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/dialog.install.sh
# Description: dialogs for installer
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

xbuild_install_restart="yes"

dialog_install_os() {
    instos=$(dialog --clear --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "Select operating systems for cross-compiling." \
        --checklist "Choose OS(es) to install." 10 50 2\
            "FreeBSD" "Install FreeBSD" on \
            "NetBSD" "Install NetBSD" off)
    rv=$? ; local rv
    if [ $rv -eq 0 ] ; then
        for i in $instos ; do
            case $i in
                FreeBSD)
                    install_freebsd_enable="yes"
                    ;;
                NetBSD)
                    install_netbsd_enable="yes"
                    ;;
            esac
        done
    else
        xbuild_install_dialog=""
    fi
}


dialog_install_netbsd_sources() {
}

dialog_install_netbsd() {
    rv=1; local rv
    while [ $rv -eq 1 ] ; do
        dialog_install_netbsd_sources
        rv=$1
    done

    #dialog_install_netbsd_pkgsrc
    #dialog_install_netbsd_docs
}

dialog_install() {
    while [ "`echo $xbuild_install_restart`" == "yes" ] ; do
        ninst=2
        dialog --clear --yes-label "Continue" --no-label "Cancel" \
            --yesno "You are about to install the xbuild-environment to your homedir." 6 40
        rv=$? ; local rv
        if [ $rv -ne 0 ] ; then
            xbuild_install_restart="no"
            return
        fi

        #check which OS(es) to install
        dialog_install_os
        if [ $? -ne 0 ] ; then
            continue
        fi

        # freebsd installation
        if [ "$install_freebsd_enable" == "yes" ] ; then
            dialog_freebsd_install
            if [ $? -ne 0 ] ; then
                continue
            fi
        fi

        # netbsd installation
        if [ "$install_netbsd_enable" == "yes" ] ; then
            dialog_install_netbsd
            if [ $? -ne 0 ] ; then
                continue
            fi
        fi
    done
}

