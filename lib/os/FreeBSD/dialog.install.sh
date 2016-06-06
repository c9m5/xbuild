#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/freebsd/dialog.install.sh
# Description: Installation dialog for FreeBSD targets
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

freebsd_dialog_install_sources() {
    listitems=""; local listitems
    if [ "`freebsd_have_system_sources`" == "yes" ] ; then
        x="`cat "${freebsd_syssrc_dir}/sys/conf/newvers.sh" | grep "REVISION=" \
            | cut -f 2 -d = - | cut -f 2 -d '"' -`" ; local x
        listitems="\"system\" \"FreeBSD-$x from system\" off"
    fi

    dialog --backtitle "${xbuild_dialog_backtitle}" \
        --title "FreeBSD Sources" \
        --infobox "Looking up FreeBSD sources ..." 4 40

    src="`freebsd_lookup_src`"; local src
    if ([ $? -ne 0 ] || [ -n "$src" ]) ; then
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "ERRORR" \
            --messagebox "Unable to lookup FreeBSD sources!" 5 50
    fi

    for i in $src ; do
        case $i in
            head)
                listitems="${listitems} \"$i\" \"FreeBSD CURRENT\" on"
                ;;
            release/*)
                listitems="${listitems} \"$i\" \"FreeBSD-`echo $i | cut -f 2 -d /` RELEASE\" off"
                ;;
            stable/*)
                listitems="${listitems} \"$i\" \"FreeBSD-`echo $i | cut -f 2 -d /` STABLE\" off"
                ;;
            releng/*)
                listitems="${listitems} \"$i\" \"FreeBSD-`echo $i | cut -f 2 -d / -` Release Engineering\" off"
                ;;
        esac
    done

    tmpf="${xbuild_tmp_dir}/instfbsddlg.tmp"; local tmpf
    cat > $tmpf << __EOF__
__real_freebsd_sources_dialog__() {
    freebsd_sources=\$(dialog --clear --stdout \\
        --backtitle "$xbuild_dialog_backtitle" \\
        --title "FreeBSD Sources" \\
        --checklist "Please choose the FreeBSD sources to install." 19 50 12 \\
        $listitems)
    return \$?
}
__EOF__
    . $tmpf
    #rm $tmpf
    __real_freebsd_sources_dialog__
    rv=$? ; local rv
    echo $rv
    if [ $rv -ne 0 ] ; then
        msg="Installation of FreeBSD canceled."
        msg="${msg}\n\n\"Restart\" restarts the installation."
        msg="${msg}\n\n\"Sources\" lets you select the FreeBSD sources again."
        msg="${msg}\n\n\"Exit\" exits the installer."
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "Source slection aborted"
            --ok-label "Restart" \
            --cancel-label "Exit" \
            --extra-button --extra-label "Sources" \
            --yesno "$msg" 12 50
        rv=$?; local rv
        case $rv in
            0|255)
                return 2 ;;
            1)
                exit ;;
            3)
                return 1 ;;
        esac
    fi

    for i in $freebsd_sources; do
        if [ "$i" == "system" ] ; then
            syssrc=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
                --title "System Sources" \
                --radiolist "Please select the install method for \"System Sources\"." 10 50 2 \
                    "symlink"   "Use a symlink"  on \
                    "nullfs"    "Nullfs mount. (requires sudo!)" off)
            : ${syssrc:="symlink"}
            local syssrc
        fi
    done
    # add sources we want to install
    for i in $freebsd_sources; do
        case $i in
            head)
                install_add_target freebsd_install_sources "FreeBSD-Current" "$i"
                ;;
            stable/*)
                install_add_target freebsd_install_sources "FreeBSD-`echo "$i" | cut -f 2 -d / -` STABLE" "$i"
                ;;
            releng/*)
                install_add_target freebsd_install_sources "FreeBSD-`echo "$i" | cut -f 2 -d / -` RELENG" "$i"
                ;;
            system)
                install_add_target freebsd_install_sources "FreeBSD System Sources" "$i" "$syssrc"
                if [ "$syssrc" == "nullfs" ] ; then
                    xbuild_install_requires_sudo="yes"
                    xbuild_install_modifies_fstab="yes"
                fi
                ;;
        esac
    done
}

freebsd_dialog_install_ports() {
    dlg_title="FreeBSD Ports Collection"; local dlg_title
    dlg_msg="Please choose where to install FreeBSD Ports from."
    if [ "`freebsd_have_system_ports`" == "yes" ] ; then
        install_ports=$(dialog --stdout \
            --backtitle "$xbuild_dialog_backtitle" \
            --title  "$dlg_title" --radiolist "$dlg_msg" 12 50 4 \
                "no" "Don't install" off \
                "system" "Ports From System" off \
                "portsnap" "Install with portsnap" on \
                "svn" "Install from svn repository" off)
        rv=$?; local rv
    else
        install_ports=$(dialog --stdout \
            --backtitle "$xbuild_dialog_backtitle" \
            --title  "$dlg_title" --radiolist "$dlg_msg" 11 50 3 \
                "no" "Don't install" off \
                "portsnap" "Install with portsnap" on \
                "svn" "Install from svn repository" off)
        rv=$?; local rv
    fi
    local install_ports

    if [ $rv -ne 0 ] ; then
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "Installing ports aborted" \
            --extra-button --extra-label "Ports" \
            --ok-label "Restart" --cancel-label "Exit" \
            --yesno "Selecting ports aborted!\nDo you want to <Restart> the installer, Rerun <Ports> dialog or <Exit> the installation?" 15 50
        rv=$?
        case $rv in
            0)
                return 2;;
            3)
                return 1;;
            1|255|*)
                exit;;
        esac
    fi

    if [ "$install_ports" == "system" ] ; then
        sysports=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
            --title "System Ports" \
            --radiolist "System Ports installation" 6 50 2 \
                "symlink"   "Use a symlink." \
                "nullfs"    "Use a nullfs mount.")

        : ${sysports:="symlink"}
        local sysports

        if [ "$sysports" == "nullfs" ] ; then
            xbuild_install_requires_sudo="yes"
            xbuild_install_modifies_fstab="yes"
        fi
    fi

    if ([ ! -z "$install_ports" ] && [ "$install_ports" != "no" ]) ; then
        if [ "$install_ports" == "system" ] ; then
            install_add_target freebsd_install_ports "FreeBSD Ports" "$install_ports" "$sysports"
        else
            install_add_target freebsd_install_ports "FreeBSD Ports" "$install_ports"
        fi
    fi
}

freebsd_dialog_install_doc() {
    dlg_title="FreeBSD Documentation"; local dlg_title
    dlg_msg="Please choose your doc install source."; local dlg_msg

    if [ "`freebsd_have_system_doc`" == "yes" ] ; then
        install_doc=$(dialog --stdout \
            --backtitle "$xbuild_dialog_backtitle" \
            --title "$dlg_title" --radiolist "$dlg_msg" 10 50 3 \
                "no" "Don't install docs" on \
                "svn" "Install docs from svn-repository." off \
                "system" "Install docs from system" off)
        rv=$?; local rv
    else
        install_doc=$(dialog --stdout \
            --backtitle "$xbuild_dialog_backtitle" \
            --title "$dlg_title" --radiolist "$dlg_msg" 9 50 2 \
                "no" "Don't install docs" on \
                "svn" "Install docs from svn-repository." off)
        rv=$?; local rv
    fi

    if [ $rv -ne 0 ] ; then
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --extra-button --extra-label "Docs" \
            --ok-label "Restart" --cancel-label "Exit" \
            --title "Install doc aborted!" \
            --yesno "Installation of FreeBSD documentation aborted!\nDo you want to <Restart> the installer, rerun the <Docs> dialog or <Exit> the installer?" 9 50

        case $rv in
            0)
                return 2 ;;
            1|255|*)
                exit ;;
            3)
                return 1 ;;
        esac
    fi

    if ([ ! -z "$install_doc" ] && [ "$install_doc" != "no" ]) ; then
        install_add_target "freebsd_install_doc" "FreeBSD Documentation" "$install_doc"
    fi
}

freebsd_dialog_install() {
    : ${FREEBSD_RELENG_ENABLE:="no"}
    : ${freebsd_releng_enable:=$FREEBSD_RELENG_ENABLE}

    install_add_target freebsd_install_base "FreeBSD Base Components"

    rv=1; local rv
    while [ $rv -eq 1 ] ; do
        freebsd_dialog_install_sources
        rv=$?
    done
    if [ $rv -ne 0 ] ; then
        return 1
    fi

    rv=1
    while [ $rv -eq 1 ] ; do
        freebsd_dialog_install_ports
        rv=$?
    done
    if [ $rv -ne 0 ] ; then
        return 1
    fi

    rv=1
    while [ $rv -eq 1 ] ; do
        freebsd_dialog_install_doc
        rv=$?
    done
    if [ $rv -ne 0 ] ; then
        return 1
    fi
}


