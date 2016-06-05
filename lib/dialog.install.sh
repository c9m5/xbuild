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
    tmpf="${xbuild_tmp_dir}/osinstdlg.tmp"; local tmpf
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
    xbuild_dialog_install="yes"
    xbuild_install_restart="yes"

    while [ "`echo $xbuild_install_restart`" == "yes" ] ; do
        xbuild_install_reset

        dialog --clear --yes-label "Continue" --no-label "Cancel" \
            --yesno "You are about to install the xbuild-environment to your homedir." 6 40
        rv=$? ; local rv
        if [ $rv -ne 0 ] ; then
            xbuild_install_restart="no"
            return
        fi

        rv=1
        while [ $rv -eq 1 ] ; do
            instdir=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
                --title "Installation Directory" \
                --dselect "$xbuild_install_dir" 20 50)
            rv=$?
            local rv instdir
            if [ $rv -eq 0 ] ; then
                if [ ! -d "$instdir" ] ; then
                    dialog --backtitle "$xbuild_dialog_backtitle" \
                        --title "Directory does not exist!" \
                        --yesno "Installation directory \"${instdir}\" does not exist.\nDo you want it to be created?" 10 40
                    rv=$?
                    if [ $rv -eq 0 ] ; then
                        xbuild_install_dir="$instdir"
                    else
                        rv=1
                    fi
                else
                    xbuild_install_dir="$instdir"
                fi
            else
                rv=2
                continue
            fi
        done
        if [ $rv -ne 0 ] ; then
            continue
        fi
        install_add_target xbuild_install_base "XBuild Base"

        #check which OS(es) to install
        dialog_install_os
        if ([ $? -ne 0 ] || [ ! "$xbuild_install_os" ]) ; then
            continue
        fi
        for i in $xbuild_install_os; do
            ${i}_dialog_install
            rv=$?
            if [ $rv -ne 0 ] ; then
                rv=1
                break
            fi
        done
        if [ $rv -ne 0 ] ; then
            continue
        fi

        if ([ "$xbuild_install_modifies_fstab" == "yes" ] && [ "$xbuild_install_requires_sudo" != "yes" ]) ; then
            xbuild_install_requires_sudo="yes"
        fi

        if [ "$xbuild_install_requires_sudo" == "yes" ] ; then
            sudo_get_password >> /dev/null
            if [ $? -ne 0 ] ; then
                # TODO: write a dialog
                dialog --backtitle "$xbuild_dialog_backtitle" \
                    --title "ERROR PASSWORD" \
                    --msgbox "Unable to determine sudo password!"
                continue
            fi
        fi

        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "Configuration complete!" \
            --yesno "XBuild configuration completed.\nIf you hit <Yes> the installation starts.\nIf you hit <No> you are brought back to the start dialog!\nDo you want to continue?" 12 50

        if [ $? -eq 0 ] ; then
            xbuild_install_restart="no"
        fi
    done
        install_add_target xbuild_install_config_files "Configuration Files"
        install_add_target xbuild_postinstall "Postinstall"

    # let's install everything in one go

}

