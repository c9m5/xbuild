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
    tmpf="${xbuild_tmp_prefix}/osinstdlg.tmp"; local tmpf
    trap "rm -f $tmpf"

    listitems=""; local listitems
    for i in `os_get_tags` ; do
        os_name=$(os_get_name_from_tag "$i"); local os_name
        clear
        if [ "`${i}_is_host`" == "yes" ] ; then
            status="on"
        else
            status="off"
        fi
        listitems="${listitems} \"$i\" \"Install $os_name\" $status"
    done
    cat > $tmpf << __EOF__
__real_install_os_dialog__() {
    xbuild_install_os=\$(dialog --clear --stdout \\
        --backtitle "$xbuild_dialog_backtitle" \\
        --title "Select operating systems for cross-compiling." \\
        --checklist "Choose OS(es) to install." 14 50 6 \\
        $listitems)
    return $?
}
__EOF__
    . $tmpf
    __real_install_os_dialog__
    rv=$?
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
        if ([ $? -ne 0 ] || [ ! "$xbuild_install_os" ]) ; then
            continue
        fi
        for i in $xbuild_install_os; do
            ${i}_dialog_install
        done
    done
}

