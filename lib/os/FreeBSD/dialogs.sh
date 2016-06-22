#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/FreeBSD/config.sh
# Description: Freebsd dialogs
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

xb_freebsd_install_sources_dialog() {
    for i in `xb_freebsd_lookup_sources`; do
        local listitems="${listitems} `echo $i | cut -f 1 -d : -` `echo $i | cut -f 2 -d : -` off"
    done
    x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "FreeBSD Sources" \
        --checklist "Please select FreeBSD-sources to install:"  20 50 15 `builtin echo ${listitems}`)
    rv=$?
    local x
    echo x
    ofile="${xbuild_tempdir}/freebsd.install.log"

    if [ $rv -eq 0 ] ; then
        local mh=`dialog --stdout --print-maxsize | cut -f 2 -w - | cut -f 1 -d ',' -`
        local mw=`dialog --stdout --print-maxsize | cut -f 3 -w -`
        w=$(( $mw - 6 ))
        local cnt=0
        for i in $x ; do
            cnt=$(( cnt + 1 ))
        done

        local n=0
        for i in $x ; do
            n=$(( $n + 1 ))
            local perc=$(( (100 * $n) / $cnt ))
            if [ $perc -gt 100 ] ; then
                perc=100
            fi
            case $i in
                head)
                    local str="FreeBSD-CURRENT"
                    ;;
                release/*)
                    local str="FreeBSD-${i##release/}-RELEASE"
                    ;;
                stable/*)
                    local str="FreeBSD-${i##stable/}-STABLE"
                    ;;
                releng/*)
                    local str="FreeBSD-${i##releng/}-RELENG"
                    ;;
            esac
            cat << EOF
XXX
${perc}
Installing ${str} ...
XXX
EOF
            xb_freebsd_install_sources $i >> $ofile
        done | dialog --backtitle "${xbuild_dialog_backtitle}" \
            --begin 3 $(( ($mw - $w) / 2 )) \
            --title "Installing FreeBSD Sources" \
            --tailboxbg "$ofile"  $(( $mh - 12 ))  $w \
            --and-widget --keep-window --begin $(( $mh - 9 )) $(( ($mw - $w) / 2 )) \
            --title "Progress" --gauge "Installing FreeBSD Sources" 6 $w 0
    fi
}

xb_freebsd_install_ports_dialog() {
    x=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
        --title "FreeBSD Ports" \
        --radiolist "Please select the installation source"  12 40 2 \
            "portsnap"  "Install with portsnap" on \
            "svn"       "Subversion"    off)
    rv=$?
    if [ $rv -eq 0 ] ; then
        local h=$(( `dialog --stdout --print-maxsize | cut -f 2 -w - | cut -f 1 -d ',' -` - 8 ))
        local w=$(( `dialog --stdout --print-maxsize | cut -f 3 -w -` - 6 ))

        xb_freebsd_install_ports $x 2>&1 | dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "Installing FreeBSD Ports" --programbox $h $w
    fi
}

xb_freebsd_install_doc() {
    local h=$(( `dialog --stdout --print-maxsize | cut -f 2 -w - | cut -f 1 -d ',' -` - 8 ))
    local w=$(( `dialog --stdout --print-maxsize | cut -f 3 -w -` - 6 ))

    xb_freebsd_install_doc 2>&1 | dialog --backtitle "$xbuild_dialog_backtitle" \
        --title "Installing FreeBSD Documentation" --programbox $h $w
}

xb_freebsd_install_menu() {
    local rv=0
    while [ $rv -eq 0 ] ; do
        x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
            --title "FreeBSD Install" \
            --menu "FreeBSD Install Menu" 12 30 5 \
                "X" "Exit" \
                "1" "Install Sources" \
                "2" "Install Ports" \
                "3" "Install Documentation")
        rv=$?
        local x
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    break;;
                1)
                    xb_freebsd_install_sources_dialog
                    ;;
                2)
                    xb_freebsd_install_ports_dialog
                    ;;
                3)
                    xb_freebsd_install_doc
                    ;;
            esac
        fi
    done
    return $rv
}

################################################################################
# Project Dialogs
################################################################################

xb_freebsd_dialog_project_select_sources() {
    for i in `ls -d ${XBUILD_BASEDIR}/src.FreeBSD*`; do
        srcitem="${srcitem} \"${i##${XBUILD_BASEDIR}/src.}\" off"
    done
    local dlg_args="--stdout --backtitle \"${xbuild_dialog_backtitle}\" --separate-widget \":\""
    local rv=0
    local src=""

    local w0="--title \"FreeBSD Sources\" --no-items --radiobox=\"Please select sources\" 10 40 4 ${srcitem}"
    local w1="--and-widget --clear --title \"Install Method\" --radiobox \"How to install sources.\" l \"Symlink sources\" on m \"Nullfs Mount\" off c \"Copy Sources\" off"
    while ([ $rv -eq 0 ] && [ -z "$src" ]); do
        src=$(eval "dialog ${dlg_args} ${w0} ${w1}")
        rv=$?
    done

    [ -z "`echo "$src" | cut -f2 -d:`" ] && src="`echo $src | cut -f1 -d:`:l"
    [ $rv -eq 0 ] && echo "$src"


    return $rv
}

xb_freebsd_dialog_project_select_ports() {
    portsitems="\"None\" \"Don't use Ports.\" on"
    if ([ "`uname -o`" == "FreeBSD" ] && [ "-r /usr/ports/Makefile" ]) ; then
        portsitems="${portsitems} \"sys:L\" \"Ports from System (SYMLINK)\" off"
        portsitems="${portsitems} \"sys:M\" \"Ports from System (NULLFSMOUNT)\" off"
        portsitems="${portsitems} \"sys:C\" \"Ports from System (COPY)\" off"
    fi
    if [ -d "${XBUILD_BASEDIR}/FreeBSD.ports" ] ; then
        portsitems="${portsitems} \"base:L\" \"Ports from XBUILD (SYMLINK)\" off"
        portsitems="${portsitems} \"base:M\" \"Ports from XBUILD (NULLFSMOUNT)\" off"
        portsitems="${portsitems} \"base:C\" \"Ports from XBUILD (COPY)\" off"
    fi
    if [ -d "${XBUILD_BASEDIR}/FreeBSD.ports-CURRENT"] ; then
        portsitems="${portsitems} \"current:L\" \"Ports from XBUILD (SYMLINK)\" off"
        portsitems="${portsitems} \"current:M\" \"Ports from XBUILD (NULLFSMOUNT)\" off"
        portsitems="${portsitems} \"current:C\" \"Ports from XBUILD (COPY)\" off"
    fi

    local dargs="--stdout --backtitle \"${xbuild_dialog_backtitle}\" --title \"FreeBSD Ports\""
    ports=$(eval "dialog ${dargs} --radiolist \"Please select install method for ports.\" 12 50 6 ${portsitems}")
    rv=$?; local rv

    [ $rv -eq 0 ] && [ -n "$ports" ] && echo "$ports"
    return $rv
}

xb_freebsd_dialog_project_new() {
    local rv=0

    local src=""
    local ports=""
    local prj_dir="$1"

    xb_project_new_add_cmd "xb_freebsd_project_new_base \"${prj_dir}\""

    while ([ $rv -eq 0 ] && [ -z "$src" ]) ; do
        src="`xb_freebsd_dialog_project_select_sources`"
        rv=$?
    done
    [ $rv -ne 0 ] && return $rv


    xb_project_new_add_cmd "xb_freebsd_project_new_sources -d "$src" \"${prj_dir}\""

    while ([ $rv -eq 0 ] && [ -z "$ports" ]) ; do
        ports="`xb_freebsd_dialog_project_select_ports`"
        rv=$?
    done
    [ $rv -ne 0 ] && return $rv

    xb_project_new_add_cmd "xb_freebsd_project_new_ports -d \"${ports}\" \"${prj_dir}\""

    for i in ${xbuild_backup_files}; do
    done

    #TODO: add doctree

    #xb_project_new_add_cmd "xb_freebsd_project_new_config \"${prj_dir}\""
}


