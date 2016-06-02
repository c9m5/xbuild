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
    if [ "`freebsd_have_system_sources`" == "yes" ] ; then
        x="`cat "${freebsd_syssrc_dir}/sys/conf/newvers.sh" | grep "REVISION=" \
            | cut -f 2 -d = - | cut -f 2 -d '"' -`" ; local x
        dlgfields="\"system\" \"FreeBSD-$x from system\" off"
    fi

    dialog --backtitle "${xbuild_dialog_backtitle}" \
        --title "FreeBSD Sources" \
        --infobox "Looking up FreeBSD sources ..." 4 40

    src="`freebsd_lookup_src`"
    if ([ $? -ne 0 ] || [ -n "$src" ]) ; then
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "ERRORR" \
            --messagebox "Unable to lookup FreeBSD sources!" 5 50
    fi

    for i in $src ; do
        case $i in
            head)
                dlgfields="${dlgfields} \"$i\" \"FreeBSD CURRENT\" on"
                ;;
            release/*)
                dlgfields="${dlgfields} \"$i\" \"FreeBSD-`echo $i | cut -f 2 -d /` RELEASE\" off"
                ;;
            stable/*)
                dlgfields="${dlgfields} \"$i\" \"FreeBSD-`echo $i | cut -f 2 -d /` STABLE\" off"
                ;;
            releng/*)
                dlgfields="${dlgfields} \"$i\" \"FreeBSD-`echo $i | cut -f 2 -d / -` Release Engineering\" off"
                ;;
        esac
    done

    tmpf="/tmp/xbuild.${LOGNAME:=$USER}.dlg.tmp"; local tmpf
    cat > $tmpf << __EOF__
__real_freebsd_sources_dialog() {
    src=\$(dialog --clear --stdout \\
        --backtitle "$xbuild_dialog_backtitle" \\
        --title "FreeBSD Sources" \\
        --checklist "Please choose the FreeBSD sources to install." 19 50 12 \\
        $dlgfields)
    return \$?
}
__EOF__
    . $tmpf
    rm $tmpf
    freebsd_src="`__real_freebsd_sources_dialog`"
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

    # calculate installation steps
    for i in $freebsd_src; do
        ninst=$(( ninst + 1 ))
    done
    return 0
}

freebsd_dialog_install_ports() {
    if [ "`freebsd_have_system_ports`" == "yes" ] ; then
        sysports_tag="system"; local sysports_tag
        sysports_info="Ports from system (/usr/ports)"; local sysports_info
        sysports_status="off"
    else
        sysports_tag=""
        sysports_info=""
        sysports_status=""
    fi
    local sysports_tag sysports_info sysports_status

    freebsd_ports=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "FreeBSD Ports Collection" \
        --radiolist "Please choose where to install FreeBSD Ports from." 15 50 4 \
            "no" "Don't install" off \
            "$sysports_tag" "$sysports_info" $sysports_status \
            "portsnap" "Install with portsnap" on \
            "svn" "Install from svn repository" off)
    if [ $? -ne 0 ] ; then
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
    if [ "$freebsd_ports" == "no" ] ; then
        install_freebsd_ports="no"
    else
        ninst=$(( $ninst + 1 ))
        install_freebsd_ports="yes"
        freebsd_ports="$ports"
    fi
    return 0
}

freebsd_dialog_install_doc() {
    if [ "`freebsd_have_system_doc`" == "yes" ] ; then
        sysdoc_tag="system"
        sysdoc_info="FreeBSD docs from system"
        sysdoc_status="off"
    else
        sysdoc_tag=""
        sysdoc_info=""
        sysdoc_status=""
    fi
    local sysdoc_tag sysdoc_info sysdoc_status

    echo "<< BEGIN DOCS >>"

    freebsd_docs=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "FreeBSD Documentation" \
        --radiolist "Please choose your doc install source." 12 50 3 \
            "no" "Don't install docs" on \
            "svn" "Install docs from svn-repository." off \
            "$sysdoc_tag" "$sysdoc_info" "$sysdoc_status")
    if [ $? -ne 0 ] ; then
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --extra-button --extra-label "Docs" \
            --ok-label "Restart" --cancel-label "Exit" \
            --title "Install doc aborted" \
            --yesno "Installation of FreeBSD documentation aborted!\nDo you want to <Restart> the installer, rerun the <Docs> dialog or <Exit> the installer?" 12 50

        case $rv in
            0)
                return 2 ;;
            1|255|*)
                exit ;;
            3)
                return 1 ;;
        esac
    fi
    if [ "$freebsd_docs" == "no" ] ; then
        install_freebsd_docs="no"
    else
        ninst=$(( $ninst + 1 ))
        install_freebsd_docs="yes"
    fi
}

freebsd_dialog_install() {
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


